"""Tests for AI insights and dashboard endpoints."""


def test_dashboard_empty(client, auth_headers):
    resp = client.get("/api/v1/insights/dashboard", headers=auth_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_habits"] == 0
    assert data["active_habits"] == 0
    assert data["insights"] == []


def test_dashboard_with_habits(client, auth_headers):
    # Create a habit and complete it
    create_resp = client.post("/api/v1/habits/", json={
        "title": "Exercise",
        "category": "fitness",
    }, headers=auth_headers)
    habit_id = create_resp.json()["id"]
    client.post(f"/api/v1/habits/{habit_id}/complete", json={"note": "Done"}, headers=auth_headers)

    resp = client.get("/api/v1/insights/dashboard", headers=auth_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert data["total_habits"] == 1
    assert data["active_habits"] == 1
    assert data["total_completions_today"] == 1
    assert len(data["insights"]) == 1
    assert data["insights"][0]["habit_title"] == "Exercise"
    assert "suggestion" in data["insights"][0]


def test_dashboard_unauthorized(client):
    resp = client.get("/api/v1/insights/dashboard")
    assert resp.status_code == 403
