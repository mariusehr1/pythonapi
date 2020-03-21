from flask import Flask, request, redirect, url_for, flash, jsonify
from pandas.api.types import is_numeric_dtype
import csv
import pandas as pd
import json

fieldnames = (
    "age","workclass","fnlwgt" ,"education","education-num","maritalstatus","occupation","relationship","race","sex",
    "capitalgain","capitalloss","hoursperweek","native-country","income"
)

dataframe = pd.read_csv("adult.data",header=None) 
dataframe.columns = fieldnames


app = Flask(__name__)

@app.route('/<column>/mean', methods=['GET'])
def mean(column):
    if is_numeric_dtype(dataframe[column]):
        result = dataframe[column].mean()
    else:
        return jsonify({'msg': "Cannot pick a mean value for a string" }), 400
    return jsonify({'result': result }), 200

@app.route('/<column>/max', methods=['GET'])
def max(column):
    result = dataframe[column].max()
    return jsonify({'result': result }), 200

@app.route('/<column>/mostfrequentvalue', methods=['GET'])
def mode(column):
    result = dataframe[column].value_counts().index[0]
    return jsonify({'result': result }), 200

@app.route('/line/<index>', methods=['GET'])
def column(index):
    result = dataframe.iloc[int(index)-1,:].to_json()
    return result
    
app.run(debug=True, host='0.0.0.0')