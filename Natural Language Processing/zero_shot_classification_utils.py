import pandas as pd
from transformers import pipeline
import torch

def run_zero_shot_classification(df, text_column, labels, model_name="valhalla/distilbart-mnli-12-3"):
    classifier = pipeline("zero-shot-classification",
                          model=model_name,
                          device=-1, 
                          truncation=True,
                          use_fast=True)

    torch.set_num_threads(1)
    texts = df[text_column].tolist()
    raw_results = classifier(texts, candidate_labels=labels)

    classification_results = pd.DataFrame([
        {**dict(zip(res['labels'], res['scores'])), 'top_choice': res['labels'][0]} 
        for res in raw_results
    ])

    final_df = pd.concat([
        df.reset_index(drop=True), 
        classification_results
    ], axis=1)
    
    return final_df


def get_model_mismatches(df_nmf, df_zero_shot, nmf_col='dominant_topic', zs_col='top_choice'):
 
    merged_df = pd.merge(df_nmf, df_zero_shot, on='abstract')
    mismatches = merged_df[merged_df[nmf_col] != merged_df[zs_col]].copy()
    
    mismatches = mismatches.rename(columns={
        nmf_col: 'nmf_topic',
        zs_col: 'zero_shot_topic'
    })

    
    cols_to_show = ['abstract', 'nmf_topic', 'zero_shot_topic']
    if 'title' in merged_df.columns:
        cols_to_show.insert(0, 'title')
        
    result = mismatches[cols_to_show]
    
    print(f"number or mismatches: {len(result)}.")
    
    return result   
