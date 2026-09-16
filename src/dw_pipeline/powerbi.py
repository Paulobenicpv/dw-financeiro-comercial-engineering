import requests
import msal
from .config import Settings


def refresh_dataset(settings: Settings) -> dict:
    if not settings.powerbi_refresh_enabled:
        return {"enabled": False, "status": "SKIPPED"}

    required = [
        settings.powerbi_tenant_id,
        settings.powerbi_client_id,
        settings.powerbi_client_secret,
        settings.powerbi_workspace_id,
        settings.powerbi_dataset_id,
    ]
    if not all(required):
        raise ValueError("POWERBI_REFRESH_ENABLED=true, mas variáveis POWERBI_* estão incompletas")

    authority = f"https://login.microsoftonline.com/{settings.powerbi_tenant_id}"
    app = msal.ConfidentialClientApplication(
        settings.powerbi_client_id,
        authority=authority,
        client_credential=settings.powerbi_client_secret,
    )
    token = app.acquire_token_for_client(
        scopes=["https://analysis.windows.net/powerbi/api/.default"]
    )
    access_token = token.get("access_token")
    if not access_token:
        raise RuntimeError(token.get("error_description", "Falha ao obter token do Power BI"))

    url = (
        f"https://api.powerbi.com/v1.0/myorg/groups/{settings.powerbi_workspace_id}"
        f"/datasets/{settings.powerbi_dataset_id}/refreshes"
    )
    response = requests.post(
        url,
        headers={"Authorization": f"Bearer {access_token}"},
        timeout=30,
    )
    response.raise_for_status()
    return {"enabled": True, "status": "REQUESTED", "http_status": response.status_code}
