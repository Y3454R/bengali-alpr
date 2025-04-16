from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import uuid
import shutil

import utils


app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "temp_uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@app.route("/", methods=["GET"])
def welcome():
    return "welcome"


@app.route("/lp-text", methods=["POST"])
def extract_lp_text():
    if "file" not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400

    # Save the uploaded file temporarily
    temp_filename = f"{uuid.uuid4()}.jpg"
    file_path = os.path.join(UPLOAD_FOLDER, temp_filename)
    file.save(file_path)

    try:
        lp_text = utils.detect_and_extract_lp_text(file_path)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        os.remove(file_path)  # Cleanup

    return jsonify({"lp_text": lp_text})


if __name__ == "__main__":
    app.run(debug=True)
