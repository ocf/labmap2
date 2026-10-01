import os
import requests
import json

prometheus_password = os.getenv("PROMETHEUS_PASSWORD")

def load_env():
    env_file = '.env'
    if os.path.exists(env_file):
        with open(env_file) as f:
            for line in f:
            # Strip whitespace and ignore lines that are empty or comments
                line = line.strip()
                if line and not line.startswith("#"):
                # Split key and value by the first '=' character
                    key, value = line.split("=", 1)
                    os.environ[key] = value  # Set as environment variable

# Prometheus server URL
prometheus_url = "https://prometheus.ocf.berkeley.edu:443/api/v1/query"

# Prometheus queries
up_query = 'up{host_type="desktop"}'
#login_query = 'node_logged_in_user{host_type="desktop", state="unlocked"}'
login_query = 'node_logged_in_user{host_type="desktop"}'

def query_prometheus(query):
    """ Query Prometheus and return the result """
    response = requests.get(prometheus_url, params={'query': query}, auth=('ocflabmap2', prometheus_password))
    if response.status_code == 200:
        result = response.json()['data']['result']
        return result
    else:
        print(f"Failed to fetch data from Prometheus: {response.status_code}")
        return []

def get_desktop_status():
    """ Get the status of all desktops (on/off, logged in/not logged in) """
    # Query for up (on/off) status
    up_result = query_prometheus(up_query)
    login_result = query_prometheus(login_query)
    
    # Create a dictionary to store the status of each desktop
    desktop_status = {}

    # Process the 'up' result
    for desktop in up_result:
        desktop_name = desktop['metric']['instance']  # Assuming 'instance' holds the desktop name
        if desktop['metric'].get('locked_status') == 'unlocked':
            continue
        desktop_status[desktop_name] = {
            'status': 'offline' if int(desktop['value'][1]) == 0 else 'online',
            'logged_in': 'unknown',  # Default value if we don't have login info yet
            'user': 'none'      # Default value for username
        }

    # Process the 'user_logged_in' result
    for desktop in login_result:
        desktop_name = desktop['metric']['instance']  # Assuming 'instance' holds the desktop name
        if desktop['metric'].get('locked_status') == 'locked':
            print("found locked status")
            continue
        username = desktop['metric'].get('name', 'unknown')  # 'name' holds the logged-in user's name
        if desktop_name in desktop_status:
            desktop_status[desktop_name]['logged_in'] = 'yes' if int(desktop['value'][1]) == 1 else 'no'
            desktop_status[desktop_name]['user'] = username

    # Convert to list format for JSON output
    desktops = [{"name": name, "status": info["status"], "logged_in": info["logged_in"], "user": info["user"]} for name, info in desktop_status.items()]

    return desktops

def generate_json():
    """ Generate the JSON structure and print it """
    desktops = get_desktop_status()
    data = {
        "desktops": desktops
    }
    
    # Convert to JSON format
    json_data = json.dumps(data, indent=4)
    
    # Print or return the JSON data (this can be sent via an API or broadcasted)
    print(json_data)
    return json_data

if __name__ == "__main__":
    load_env()
    prometheus_password = os.getenv("PROMETHEUS_PASSWORD")
    generate_json()
