import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import NMF

def run_tfidf(text_series, min_df=1, max_df=1.0, stop_words=None):
    vectorizer = TfidfVectorizer(stop_words=stop_words, min_df=min_df, max_df=max_df)
    tfidf_matrix = vectorizer.fit_transform(text_series)
    tfidf_df = pd.DataFrame(tfidf_matrix.toarray(), columns=vectorizer.get_feature_names_out())
    return vectorizer, tfidf_df

def display_topics(tv, H, num_words=10):
    for topic_num, topic_array in enumerate(H):
        top_features = topic_array.argsort()[::-1][:num_words]
        top_words = [tv.get_feature_names_out()[i] for i in top_features]
        print(f"Topic {topic_num+1}: {', '.join(top_words)}")

def run_nmf_and_display(tfidf_df, tv, n_topics=5, num_words=10):
    nmf = NMF(n_components=n_topics, random_state=42, max_iter=500)
    W = nmf.fit_transform(tfidf_df)
    H = nmf.components_
    display_topics(tv, H, num_words)
    return W, H

def get_abstracts_with_topics(abstracts_df, W, topic_names):
    doc_topics = pd.DataFrame(W, columns=topic_names)
    doc_topics['dominant_topic'] = doc_topics.idxmax(axis=1)
    result_df = pd.concat([abstracts_df.reset_index(drop=True), doc_topics], axis=1)
    return result_df

def get_topic_stats(df, col='dominant_topic'):
    counts = df[col].value_counts()
    percent = df[col].value_counts(normalize=True) * 100
    
    summary = pd.DataFrame({
        'count': counts,
        'percent': percent.round(2)
    })
    return summary

def plot_quarterly_distribution(df, topic_names, col = 'dominant_topic', save_path='topic_distribution_plot.pdf'):

    quarterly_counts = df.groupby(['time', col]).size().unstack(fill_value=0)
    quarterly_percent = quarterly_counts.div(quarterly_counts.sum(axis=1), axis=0) * 100
    
    quarterly_percent = quarterly_percent[topic_names]
    
    deep_palette = sns.color_palette("Paired", n_colors=len(topic_names))
    ax = quarterly_percent.plot(kind='bar', stacked=True, figsize=(14, 8), 
                                color=deep_palette, width=0.8, edgecolor='white', linewidth=0.7)
    
    plt.title('Quarterly Distribution of Research Topics in the Ecology Letters Journal', 
              fontsize=16, pad=20, fontweight='bold')
    plt.xlabel('Time Period (Quarter)', fontsize=12)
    plt.ylabel('Percentage Share (%)', fontsize=12)
    plt.legend(title='Research Topics', bbox_to_anchor=(1.02, 1), loc='upper left', frameon=False)
    
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    plt.xticks(rotation=45)
    plt.grid(axis='y', linestyle='--', alpha=0.3)
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, bbox_inches='tight', dpi=300)
    plt.show()
    
    return quarterly_percent.round(2)


def get_top_documents_per_topic(df, topic_names, num_docs=1):
    for topic in topic_names:
        print(f"TOP DOCUMENTS FOR TOPIC: {topic.upper()}")
        top_results = df.sort_values(by=topic, ascending=False).head(num_docs)
        
        for i, (idx, row) in enumerate(top_results.iterrows()):
            score = row[topic]
            title = row.get('title', 'No Title')
            abstract = row.get('abstract', 'No Abstract')
            
            if num_docs > 1:
                print(f"\n--- Result #{i+1} (Score: {score:.4f}) ---")
            else:
                print(f"Score: {score:.4f}")
                
            print(f"Title: {title}")
            print(f"Abstract: {abstract[:500]}...") 
            print("-" * 50)
        print("\n")