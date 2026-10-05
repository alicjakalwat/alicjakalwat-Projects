import requests
import pandas as pd
import spacy

BASE_URL = "https://api.semanticscholar.org/graph/v1/paper/search/bulk"


def search_papers(
    query=None,
    venue=None,
    fields_of_study=None,
    publication_types=None,
    date_range=None,
    sort="publicationDate",
):
    params = {
        "fields": "paperId,title,year,abstract,venue,publicationDate",
        "sort": sort,
    }

    if query:
        params["query"] = query
    if venue:
        params["venue"] = venue
    if fields_of_study:
        params["fieldsOfStudy"] = fields_of_study
    if publication_types:
        params["publicationTypes"] = publication_types
    if date_range:
        params["publicationDateOrYear"] = date_range

    response = requests.get(BASE_URL, params=params)
    if response.status_code != 200:
        raise RuntimeError(f"SemanticScholar API error {response.status_code}: {response.text}")

    return response.json()


def search_papers_for_ranges(date_ranges, **kwargs):
    if not isinstance(date_ranges, (list, tuple)):
        raise ValueError("`date_ranges` must be a list or tuple of range strings")

    results = []
    for date_range in date_ranges:
        results.append(search_papers(date_range=date_range, **kwargs))
    return results


def results_to_dataframe(results):
    frames = []
    for result in results:
        data = result.get("data", [])
        if data:
            frames.append(pd.DataFrame(data))

    if not frames:
        return pd.DataFrame()

    return pd.concat(frames, ignore_index=True)


def annotate_dates(df):
    df = df.copy()
    df["publicationDate"] = pd.to_datetime(df["publicationDate"], errors="coerce")
    df["month"] = df["publicationDate"].dt.month.fillna(1).astype(int)
    df["quarter"] = ((df["month"] - 1) // 3 + 1).astype(int)
    df["time"] = df["year"].astype(str) + "-Q" + df["quarter"].astype(str)
    return df


def summary_missing_abstracts_by_year(df):
    summary = (
        df.groupby(["year"])
          .agg(
              total=("abstract", "size"),
              nan_abstracts=("abstract", lambda x: x.isna().sum())
          )
    )
    summary["fraction_nan"] = summary["nan_abstracts"] / summary["total"]
    return summary


def clean_dataframe(df, year_min=2020, year_max=2025):
    df = annotate_dates(df)
    cols = ["paperId", "title", "venue", "year", "abstract", "month", "quarter", "time", "publicationDate"]
    df = df[cols].dropna(subset=["abstract"])
    return df.query("year >= @year_min and year <= @year_max").reset_index(drop=True)


# --- text preprocessing functions ---

_nlp = None

def get_nlp_model(model_name="en_core_web_sm"):
    global _nlp
    if _nlp is None:
        _nlp = spacy.load(model_name)
    return _nlp

def lower_replace(series):
    output = series.str.lower()
    output = output.str.replace(r"\babstract\b", "", regex=True)
    output = output.str.replace(r"\[.*?\]", "", regex=True)
    output = output.str.replace(r"[^\w\s]", "", regex=True)
    return output


def token_lemma_nonstop(text, nlp_model=None):
    nlp_model = nlp_model or get_nlp_model()
    doc = nlp_model(text)
    tokens = [token.lemma_ for token in doc if not token.is_stop]
    return " ".join(tokens)


def filter_pos(text, pos_list=["NOUN", "PROPN"], nlp_model=None):
    nlp_model = nlp_model or get_nlp_model()
    doc = nlp_model(text)
    tokens = [token.text for token in doc if token.pos_ in pos_list]
    return " ".join(tokens)


def nlp_pipeline(series, nlp_model=None):
    nlp_model = nlp_model or get_nlp_model()
    output = lower_replace(series)
    output = output.apply(lambda t: token_lemma_nonstop(t, nlp_model=nlp_model))
    output = output.apply(lambda t: filter_pos(t, nlp_model=nlp_model))
    return output
