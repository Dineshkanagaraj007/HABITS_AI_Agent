"""Tests for habit CRUD and completion endpoints."""


def test_create_habit(client, auth_headers):
    resp = client.post("/api/v1/habits/", json={
        "title": "Morning Run",
        "description": "Run 5km every morning",
        "category": "fitness",
        "frequency": "daily",
    }, headers=auth_headers)
    assert resp.status_code == 201
    data = resp.json()
    assert data["title"] == "Morning Run"
    assert data["category"] == "fitness"
    assert data["completion_count"] == 0


def test_list_habits(client, auth_headers):
    client.post("/api/v1/habits/", json={"title": "Habit A"}, headers=auth_headers)
    client.post("/api/v1/habits/", json={"title": "Habit B"}, headers=auth_headers)
    resp = client.get("/api/v1/habits/", headers=auth_headers)
    assert resp.status_code == 200
    assert len(resp.json()) == 2


def test_get_habit(client, auth_headers):
    create_resp = client.post("/api/v1/habits/", json={"title": "Read"}, headers=auth_headers)
    habit_id = create_resp.json()["id"]
    resp = client.get(f"/api/v1/habits/{habit_id}", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["title"] == "Read"


def test_update_habit(client, auth_headers):
    create_resp = client.post("/api/v1/habits/", json={"title": "Old"}, headers=auth_headers)
    habit_id = create_resp.json()["id"]
    resp = client.patch(f"/api/v1/habits/{habit_id}", json={"title": "New"}, headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["title"] == "New"


def test_delete_habit(client, auth_headers):
    create_resp = client.post("/api/v1/habits/", json={"title": "Delete Me"}, headers=auth_headers)
    habit_id = create_resp.json()["id"]
    resp = client.delete(f"/api/v1/habits/{habit_id}", headers=auth_headers)
    assert resp.status_code == 204

    resp = client.get(f"/api/v1/habits/{habit_id}", headers=auth_headers)
    assert resp.status_code == 404


def test_complete_habit(client, auth_headers):
    create_resp = client.post("/api/v1/habits/", json={"title": "Meditate"}, headers=auth_headers)
    habit_id = create_resp.json()["id"]

    resp = client.post(f"/api/v1/habits/{habit_id}/complete", json={
        "note": "Felt great!",
        "rating": 8.0,
    }, headers=auth_headers)
    assert resp.status_code == 201
    assert resp.json()["rating"] == 8.0


def test_list_completions(client, auth_headers):
    create_resp = client.post("/api/v1/habits/", json={"title": "Journal"}, headers=auth_headers)
    habit_id = create_resp.json()["id"]
    client.post(f"/api/v1/habits/{habit_id}/complete", json={"note": "Day 1"}, headers=auth_headers)
    client.post(f"/api/v1/habits/{habit_id}/complete", json={"note": "Day 2"}, headers=auth_headers)

    resp = client.get(f"/api/v1/habits/{habit_id}/completions", headers=auth_headers)
    assert resp.status_code == 200
    assert len(resp.json()) == 2


def test_habit_not_found(client, auth_headers):
    resp = client.get("/api/v1/habits/nonexistent", headers=auth_headers)
    assert resp.status_code == 404


def test_unauthorized_access(client):
    resp = client.get("/api/v1/habits/")
    assert resp.status_code == 403
