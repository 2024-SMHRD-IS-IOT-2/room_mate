from flask import Flask, request, jsonify, send_file
import matplotlib.pyplot as plt
import boto3
from dotenv import load_dotenv
import os

app = Flask(__name__)

map_data = 'C:/Users/choihongcheol/Desktop/room_mate_total/room_mate_server/map.jpg' # 맵핑된 데이터
robot_location = None # 실시간 로봇 데이터
destination = None # app에서 찍은 위치 데이터
stop_moving = None # 멈춤 신호
coordinate = None # 목적지 좌표값
load_dotenv() # .env 파일을 로드하라

AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION_NAME = os.getenv("REGION_NAME")

img_color = plt.imread(map_data)
# plt.imshow(img_color)
# plt.show()

######################################################################
# robot에서 지도데이터 보냄(robot -> server)
@app.route('/map_data', methods=['POST'])
def map_data():
    global map_data
    data = request.json
    map_data = data
    return f'Map data received successfully : ${map_data}'

# robot에서 받은 지도를 app에 보냄(server -> app)
@app.route('/to_flutter_map_data', methods=['GET'])
def to_flutter_map_data():
    map_data = 'C:/Users/smhrd/Desktop/final_project/map.jpg' # robot에서 받은 데이터
    if map_data:
        return send_file(map_data, mimetype='image/jpg')
    else:
        return 'No data available(map_data)'
######################################################################
######################################################################
######################################################################
# 실시간 robot위치 보냄(robot -> server)
@app.route('/robot_location', methods=['POST'])
def robot_location():
    global robot_location
    data = request.json
    robot_location = data
    return f'Robot location received successfully ${robot_location}'


# 실시간 robot위치 보냄(server -> app)
@app.route('/to_flutter_robot_location', methods=['POST']) 
def to_flutter_robot_location():
    global robot_location
    if robot_location:
        return jsonify(robot_location)
    else:
        return 'No data available(robot_location)'
######################################################################
######################################################################
######################################################################
# app에서 로봇위치 찍으면 그 좌표값을 robot에 보냄(app -> server)
@app.route('/destination', methods=['POST'])
def destination():
    global destination
    data = request.json
    destination = data
    print("목적지 :", destination)
    return f'destination received successfully ${destination}'

# app에서 로봇위치 찍으면 그 좌표값을 robot에 보냄(server -> robot)
@app.route('/to_robot_destination', methods=['POST'])
def to_robot_destination():
    global destination
    if destination:
        return jsonify(destination)
    else:
        return 'No data available(destination)'
######################################################################
######################################################################
######################################################################
# app에서 집으로 버튼 누르면 집으로 가도록 집 좌표값 보냄(app -> server)
@app.route('/go_to_home', methods=['POST'])
def goToHome():
    global destination
    data = request.json
    destination = data
    print('집 좌표 :', destination)
    return f'home coordinate received successfully ${destination}'

@app.route('/to_robot_go_to_home', methods=['POST'])
def toRobotGoToHome():
    global destination
    if destination:
        return jsonify(destination)
    else:
        return 'No data available(destination)'
######################################################################
######################################################################
######################################################################
# 주행 중, app에서 stop신호 보냄(app -> server)
@app.route('/stop', methods=['POST'])
def stop():
    global stop_moving
    data = request.json
    stop_moving = data
    print('멈춰!', stop_moving['stop_signal'])
    return f'Stop!! ${stop_moving}'

# 주행 중, app에서 stop신호 보냄(server -> robot)
@app.route('/to_robot_stop', methods=['POST'])
def to_robot_stop():
    global stop_moving
    if stop_moving:
        return jsonify(stop_moving)
    else:
        return 'No data available(stop_moving)'
######################################################################
######################################################################
######################################################################
# 도착 시, 찍은 사진 서버에서 받기(robot -> server)
#   => aws로 보내기
#   => 이건 server거치지 않고 그냥 robot에서 바로 aws로 보냄
# @app.route('/from_robot_photos')
# def from_robot_photos():


######################################################################
######################################################################
######################################################################
# 모든 사진 앱으로 보내기(aws -> server -> app)
#   => aws에서 받아서 app으로 보내기
s3 = boto3.resource('s3',
                   aws_access_key_id=AWS_ACCESS_KEY_ID,
                   aws_secret_access_key=AWS_SECRET_ACCESS_KEY)

@app.route('/get_photos', methods=['GET'])
def get_photos():
    try:
        # S3에서 이미지 파일 목록 가져오기
        bucket = s3.Bucket('jjury')
        photo_files = [obj.key for obj in bucket.objects.filter(Prefix='')] # Prefix : 안에 있는 폴더의 모든 파일들을 선택(''이므로 폴더 없이 버킷 안에 있는 모든 파일들 선택!)

        # 각 이미지 파일의 URL 생성
        photo_urls = [f'https://{bucket.name}.s3.amazonaws.com/{file_name}' for file_name in photo_files]

        return jsonify(photo_urls)
    except Exception as e:
        return str(e), 400

######################################################################
######################################################################
######################################################################
# app에서 삭제버튼 누른 이미지 삭제하기(app -> server -> aws)

# AWS_ACCESS_KEY_IDB = os.getenv('AKIA6GBMAY4L3VTRGBHH')
# AWS_SECRET_ACCESS_KEYB = os.getenv('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')
# REGION_NAMEB = 'us-east-2'

@app.route('/delete_photos', methods=['POST'])
def deletePhotos():
    data = request.json
    photo_names =  data['photos'] # 삭제할 사진 리스트
    bucket_name = 'jjury'
    
    for photo_name in photo_names:
        try:
            s3_client = boto3.client(
                's3',
                # endpoint_url='https://jjury.s3.amazonaws.com',
                aws_access_key_id=AWS_ACCESS_KEY_ID,
                aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                region_name=REGION_NAME
            )
            # obj = s3.Object(bucket_name, photo_name)
            # obj.delete()
            s3_client.delete_object(Bucket=bucket_name, Key=photo_name[31:]) # slicing을 해야 객체 이름만 뽑힌다 앞의 http://jjury.s3.amazoneaws.com/ 없애야함!!
            print('됐다!')
        except Exception as e:
            print(f"Error deleting {photo_name}: {e}")
            return jsonify({"error": f"Failed to delete some photos: {e}"}), 500
        
    # return jsonify({'message' : "Photos deleted successfully"}), 200

    print('삭제될 사진들 :', photo_names)
    print(type(photo_names))
    
    return photo_names
    # try:
    # photoList =s3.Bucket(data)
    # s3.Object('jjury', i.key).delete()
    # except Exception as e:
    #     return str(e), 400

######################################################################
######################################################################
######################################################################

if __name__ == '__main__':
    app.run(host='192.168.70.48', port=8016)