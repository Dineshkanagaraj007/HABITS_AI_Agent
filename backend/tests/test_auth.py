"""Tests for authentication endpoints."""


def test_register_user(client):
    resp = client.post("/api/v1/auth/register", json={
        "email": "new@example.com",
        "username": "newuser",
        "password": "secret123",
        "full_name": "New User",
    })
    assert resp.status_code == 201
    data = resp.json()
    assert data["email"] == "new@example.com"
    assert data["username"] == "newuser"
    assert "id" in data


def test_register_duplicate_email(client):
    payload = {
        "email": "dup@example.com",
        "username": "user1",
        "password": "secret123",
    }
    client.post("/api/v1/auth/register", json=payload)
    payload["username"] = "user2"
    resp = client.post("/api/v1/auth/register", json=payload)
    assert resp.status_code == 400
    assert "Email already registered" in resp.json()["detail"]


def test_register_duplicate_username(client):
    payload = {
        "email": "a@example.com",
        "username": "sameuser",
        "password": "secret123",
    }
    client.post("/api/v1/auth/register", json=payload)
    payload["email"] = "b@example.com"
    resp = client.post("/api/v1/auth/register", json=payload)
    assert resp.status_code == 400
    assert "Username already taken" in resp.json()["detail"]


def test_login_success(client):
    client.post("/api/v1/auth/register", json={
        "email": "login@example.com",
        "username": "loginuser",
        "password": "mypassword",
    })
    resp = client.post("/api/v1/auth/login", json={
        "username": "loginuser",
        "password": "mypassword",
    })
    assert resp.status_code == 200
    assert "access_token" in resp.json()


def test_login_invalid_credentials(client):
    resp = client.post("/api/v1/auth/login", json={
        "username": "nobody",
        "password": "wrong",
    })
    assert resp.status_code == 401


def test_get_me(client, auth_headers):
    resp = client.get("/api/v1/auth/me", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["username"] == "testuser"


def test_get_me_no_token(client):
    resp = client.get("/api/v1/auth/me")
    assert resp.status_code == 403
