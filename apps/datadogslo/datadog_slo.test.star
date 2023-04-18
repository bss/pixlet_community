load("testing.star", "testing")
load("encoding/json.star", "json")

def test_no_api_key(config):
    config = {
        "api_key": "",
    }
    http_response = {
        "status_code": 403,
        "headers": {"Content-Type": "application/json"},
        "body": json.encode({"status":"error","code":403,"errors":["Forbidden"],"statuspage":"http://status.datadoghq.com","twitter":"http://twitter.com/datadogops","email":"support@datadoghq.com"})
    }
    testing.stub_http(
        lambda method, url, **kwargs: method == "GET" and url.startswith("https://api.datadoghq.com/api/v1/slo/"),
        lambda method, url, **kwargs: http_response
    )
    root = main(config)
    testing.assert_render_webp(root, "test_files/invalid_api_key.webp")

def test_slo_with_warning_red(config):
    config = {
        "api_key": "API_KEY",
        "app_key": "APP_KEY",
        "slo_id": "SLO_ID",
        "timewindow": "30d",
    }
    http_response = success_http_response(98.12, True)
    testing.stub_http(
        lambda method, url, **kwargs: method == "GET" and url.startswith("https://api.datadoghq.com/api/v1/slo/"),
        lambda method, url, **kwargs: http_response
    )
    root = main(config)
    testing.assert_render_webp(root, "test_files/slo_with_warning_red.webp")

def test_slo_with_warning_yellow(config):
    config = {
        "api_key": "API_KEY",
        "app_key": "APP_KEY",
        "slo_id": "SLO_ID",
        "timewindow": "30d",
    }
    http_response = success_http_response(99.992, True)
    testing.stub_http(
        lambda method, url, **kwargs: method == "GET" and url.startswith("https://api.datadoghq.com/api/v1/slo/"),
        lambda method, url, **kwargs: http_response
    )
    root = main(config)
    testing.assert_render_webp(root, "test_files/slo_with_warning_yellow.webp")

def test_slo_with_warning_green(config):
    config = {
        "api_key": "API_KEY",
        "app_key": "APP_KEY",
        "slo_id": "SLO_ID",
        "timewindow": "30d",
    }
    http_response = success_http_response(99.998, True)
    testing.stub_http(
        lambda method, url, **kwargs: method == "GET" and url.startswith("https://api.datadoghq.com/api/v1/slo/"),
        lambda method, url, **kwargs: http_response
    )
    root = main(config)
    testing.assert_render_webp(root, "test_files/slo_with_warning_green.webp")

def test_slo_red(config):
    config = {
        "api_key": "API_KEY",
        "app_key": "APP_KEY",
        "slo_id": "SLO_ID",
        "timewindow": "30d",
    }
    http_response = success_http_response(98.45, False)
    testing.stub_http(
        lambda method, url, **kwargs: method == "GET" and url.startswith("https://api.datadoghq.com/api/v1/slo/"),
        lambda method, url, **kwargs: http_response
    )
    root = main(config)
    testing.assert_render_webp(root, "test_files/slo_red.webp")

def test_slo_green(config):
    config = {
        "api_key": "API_KEY",
        "app_key": "APP_KEY",
        "slo_id": "SLO_ID",
        "timewindow": "30d",
    }
    http_response = success_http_response(99.992, False)
    testing.stub_http(
        lambda method, url, **kwargs: method == "GET" and url.startswith("https://api.datadoghq.com/api/v1/slo/"),
        lambda method, url, **kwargs: http_response
    )
    root = main(config)
    testing.assert_render_webp(root, "test_files/slo_green.webp")

def success_http_response(sli_value, has_warning):
    if has_warning:
        thresholds = {
                        "7d": {
                            "timeframe": "7d",
                            "target": 99.99,
                            "target_display": "99.99",
                            "warning": 99.995,
                            "warning_display": "99.995"
                        },
                        "30d": {
                            "timeframe": "30d",
                            "target": 99.99,
                            "target_display": "99.99",
                            "warning": 99.995,
                            "warning_display": "99.995"
                        },
                        "90d": {
                            "timeframe": "90d",
                            "target": 99.99,
                            "target_display": "99.99",
                            "warning": 99.995,
                            "warning_display": "99.995"
                        }
                    }
    else:
        thresholds = {
                        "7d": {
                            "timeframe": "7d",
                            "target": 99.99,
                            "target_display": "99.99",
                        },
                        "30d": {
                            "timeframe": "30d",
                            "target": 99.99,
                            "target_display": "99.99",
                        },
                        "90d": {
                            "timeframe": "90d",
                            "target": 99.99,
                            "target_display": "99.99",
                        }
                    }
    return {
        "status_code": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.encode(
            {
                "data": {
                    "thresholds": thresholds,
                    "from_ts": 1679332589,
                    "to_ts": 1679937389,
                    "type": "metric",
                    "type_id": 1,
                    "slo": {
                        "id": "SLO_ID",
                        "name": "Request Success",
                        "tags": [],
                        "monitor_tags": [],
                        "type": "metric",
                        "type_id": 1,
                        "description": "Delivering requests successfully.",
                        "timeframe": "90d",
                        "warning_threshold": 99.995,
                        "target_threshold": 99.99,
                        "query": {
                            "denominator": "count:app.response_time{*}",
                            "numerator": "count:app.response_time{status_code:2* OR status_code:3*}"
                        },
                        "creator": {
                            "name": "John Doe",
                            "handle": "john@example.com",
                            "email": "john@example.com"
                        },
                        "created_at": 1677769003,
                        "modified_at": 1677790399
                    },
                    "overall": {
                        "errors": None,
                        "sli_value": sli_value,
                        "span_precision": 4,
                        "precision": {
                            "7d": 4,
                            "30d": 4,
                            "90d": 4
                        },
                        "corrections": []
                    }
                },
                "errors": None
            }
        )
    }