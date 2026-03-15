from flask import Flask, jsonify
import platform
import datetime
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <html>
    <head><title>Docker Python App</title>
    <style>
        body { font-family: Arial, sans-serif; background: #1e1e2e; color: #cdd6f4; padding: 40px; }
        h1 { color: #89b4fa; }
        .card { background: #313244; border-radius: 10px; padding: 20px; max-width: 600px; margin: 20px auto; }
        .label { color: #a6e3a1; font-weight: bold; }
    </style>
    </head>
    <body>
        <div class="card">
            <h1>🐳 Docker Python App</h1>
            <p><span class="label">Status:</span> Running inside Docker on AWS ✅</p>
            <p><span class="label">Hostname:</span> """ + socket.gethostname() + """</p>
            <p><span class="label">Python:</span> """ + platform.python_version() + """</p>
            <p><span class="label">OS:</span> """ + platform.system() + " " + platform.release() + """</p>
            <p><span class="label">Time (UTC):</span> """ + datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S") + """</p>
            <hr style="border-color:#585b70;">
            <p>Try <a href="/api/info" style="color:#89dceb;">/api/info</a> for JSON output</p>
        </div>
    </body>
    </html>
    """

@app.route("/api/info")
def api_info():
    return jsonify({
        "status": "running",
        "message": "Hello from Docker container on AWS!",
        "hostname": socket.gethostname(),
        "python_version": platform.python_version(),
        "os": platform.system() + " " + platform.release(),
        "timestamp_utc": datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
