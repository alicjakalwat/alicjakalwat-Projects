import numpy as np
import pandas as pd
from transformers import pipeline
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib.pyplot as plt
import seaborn as sns

def calculate_cosine_similarity(df, text_column, reference_text, model_name="BAAI/bge-small-en-v1.5"):


    feature_extractor = pipeline("feature-extraction", 
                                 model=model_name, 
                                 device=-1, 
                                 use_fast=True)

    ref_raw = feature_extractor(reference_text)
    ref_embedding = np.array(ref_raw[0][0]).reshape(1, -1)

    abstracts_raw = feature_extractor(df[text_column].tolist())
    
    abstracts_embeddings = np.array([res[0][0] for res in abstracts_raw])

    cos_sim = cosine_similarity(abstracts_embeddings, ref_embedding)

    result_df = df.copy()
    result_df["cosine_similarity"] = cos_sim[:, 0]
    
    return result_df

def get_single_score(text, reference_text, model_name="BAAI/bge-small-en-v1.5"):
    
    temp_df = pd.DataFrame({'text': [text]})
    result_df = calculate_cosine_similarity(temp_df, 'text', reference_text, model_name)
    
    return result_df["cosine_similarity"].iloc[0]    
    

def get_similarity_extremes(df, n=5, highest=True, col='cosine_similarity'):

    available_cols = df.columns.tolist()
    target_cols = [c for c in ['year', 'title', 'abstract', col] if c in available_cols]
    
    if highest:
        result = df.nlargest(n, col)[target_cols]
        print(f"--- Top {n} MOST similar abstracts to Aims & Scope ---")
    else:
        result = df.nsmallest(n, col)[target_cols]
        print(f"--- Top {n} LEAST similar abstracts to Aims & Scope ---")
    
    return result


def plot_similarity_histogram(df, col='cosine_similarity', save_path="histogram_similarities.png"):
    
    plt.figure(figsize=(10, 5))
    sns.histplot(df[col], bins='auto', color='skyblue', edgecolor='black')
    
    plt.title('Distribution of Cosine Similarity Score')
    plt.xlabel('Similarity Score')
    plt.ylabel('Frequency')

    sns.despine()

    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()
    plt.show()


def plot_similarity_boxplot(df, col='cosine_similarity', save_path="boxplot_similarities.png"):
    
    plt.figure(figsize=(10, 5))
    bplot = plt.boxplot(df[col], vert=False, patch_artist=True, tick_labels=["Abstracts"])
    
    bplot['boxes'][0].set_facecolor('skyblue')
    
    plt.title("Boxplot of Cosine Similarity Scores")
    plt.xlabel("Similarity Score")
    plt.grid(axis='x', linestyle='--', alpha=0.7)
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()


def plot_quarterly_similarity(df, time_col='time', sim_col='cosine_similarity', save_path="similarities_over_time.png"):

    plt.figure(figsize=(14, 6))
    
    df_sorted = df.sort_values(by=time_col)
    
    sns.lineplot(data=df_sorted, x=time_col, y=sim_col, 
                 marker='o', color='teal', linewidth=2.5, 
                 errorbar=('ci', 95))

    plt.title('Quarterly Similarity Trend with 95% Confidence Interval', 
              fontsize=14, fontweight='bold', pad=15)
    plt.xlabel('Quarter (Year-Q)', fontsize=12)
    plt.ylabel('Cosine Similarity Score', fontsize=12)
    
    plt.xticks(rotation=45)
    plt.grid(axis='y', linestyle='--', alpha=0.3)
    sns.despine()
    
    plt.tight_layout()
    plt.show()

    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()
    