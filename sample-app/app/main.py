from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return f'VERSI 1'

@app.route("/healthz")
def healthz():
    return "OK"
    
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
