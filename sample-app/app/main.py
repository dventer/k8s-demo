from flask import Flask
import psutil
app = Flask(__name__)

@app.route("/")
def index():
    cpu = psutil.cpu_percent()
    memory = psutil.virtual_memory()[2]
    return f'CPU = {cpu}<br/>Memory = {memory}'

@app.route("/healthz")
def healthz():
    return "Ok Brooo"

@app.route("/login")
def login():
    return "contoh path login "
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
