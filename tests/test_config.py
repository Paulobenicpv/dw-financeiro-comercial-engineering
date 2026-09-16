from dw_pipeline.config import load_entities


def test_entities_order():
    entities = load_entities("config/entities.yml")
    assert list(entities.keys()) == [
        "clientes", "produtos", "vendedores", "vendas", "metas", "despesas"
    ]
