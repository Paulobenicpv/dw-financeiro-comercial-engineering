import pandas as pd
from dw_pipeline.quality import validate_dataframe


def test_duplicate_business_key_is_detected():
    df = pd.DataFrame({
        "venda_id": [1, 1],
        "quantidade": [1, 2],
        "preco_unitario": [10, 20],
    })
    spec = {
        "required": ["venda_id"],
        "business_keys": ["venda_id"],
        "positive": ["quantidade"],
        "nonnegative": ["preco_unitario"],
    }
    results = validate_dataframe("vendas", df, spec)
    duplicate = [r for r in results if r["rule"].startswith("duplicate_business_key")][0]
    assert duplicate["count"] == 2


def test_valid_dataframe_passes():
    df = pd.DataFrame({
        "venda_id": [1, 2],
        "quantidade": [1, 2],
        "preco_unitario": [10, 20],
    })
    spec = {
        "required": ["venda_id"],
        "business_keys": ["venda_id"],
        "positive": ["quantidade"],
        "nonnegative": ["preco_unitario"],
    }
    assert all(r["count"] == 0 for r in validate_dataframe("vendas", df, spec))
