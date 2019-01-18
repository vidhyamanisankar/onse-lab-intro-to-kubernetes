from app import app

def test_something():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert response.is_json

    body = response.get_json()

    assert 'message' in body
    assert body['message'] == 'Hello'
