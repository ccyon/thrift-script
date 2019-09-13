from tchannel import TChannel, thrift
from tornado import gen, ioloop
import pandas as pd
import sys

proj_name = 'driver_dedupe_v2'
model_id = 'tm20190120-095846-KQXLYNRF-ZFIENG'
ma_group='michelangelo-prediction-group1'

tchannel = TChannel('michelangelo-test')
michelangelo_thrift_path = './predictionservice.thrift'

prediction_service = thrift.load(
    path=michelangelo_thrift_path,
    service='michelangelo-gateway',
    hostport='127.0.0.1:6424'
)

headers={'x-uber-source': 'fraud_onetime'}
loop = ioloop.IOLoop()

def michelangelo_output(projectId, modelId, michelangelo_group, test_data):
    predictions = []

    for index, row in test_data.iterrows():
        basis_features = [
            prediction_service.ValueItem(
                stringValue=str(row["driver_uuid1"]),
                key="driver_uuid1"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["driver_uuid2"]),
                key="driver_uuid2"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["concat_name_edit_distance"]),
                key="concat_name_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["firstname_edit_distance"]),
                key="firstname_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["lastname_edit_distance"]),
                key="lastname_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["email_edit_distance"]),
                key="email_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["mobile_edit_distance"]),
                key="mobile_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["concat_name_longest_common_sub"]),
                key="concat_name_longest_common_sub"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["firstname_longest_common_sub"]),
                key="firstname_longest_common_sub"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["lastname_longest_common_sub"]),
                key="lastname_longest_common_sub"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["email_longest_common_sub"]),
                key="email_longest_common_sub"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["mobile_longest_common_sub"]),
                key="mobile_longest_common_sub"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["same_email_domain"]),
                key="same_email_domain"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["signup_at_diff_days"]),
                key="signup_at_diff_days"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["activation_at_diff_days"]),
                key="activation_at_diff_days"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["drivers_license_edit_distance"]),
                key="drivers_license_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["national_id_edit_distance"]),
                key="national_id_edit_distance"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_devices"]),
                key="num_same_devices"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_device_carriers"]),
                key="num_same_device_carriers"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_device_os"]),
                key="num_same_device_os"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_device_model"]),
                key="num_same_device_model"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_imei"]),
                key="num_same_imei"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["banned_device_sides"]),
                key="banned_device_sides"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_vehicle"]),
                key="num_same_vehicle"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_vehicle_make"]),
                key="num_same_vehicle_make"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_vehicle_model"]),
                key="num_same_vehicle_model"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_vehicle_year"]),
                key="num_same_vehicle_year"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_same_vin_number"]),
                key="num_same_vin_number"
            ),
            prediction_service.ValueItem(
                stringValue=str(row["num_shared_plates"]),
                key="num_shared_plates"
            )
        ]

        @gen.coroutine
        def get_response():
            response = yield tchannel.thrift(
                prediction_service.PredictionService.predict(
                    prediction_service.PredictionRequest(
                        projectId=projectId,
                        modelId=modelId,
                        basisFeatures=basis_features
                    )
                ),
                headers=headers,
                shard_key=michelangelo_group
            )
            raise gen.Return(response.body)

        result = loop.run_sync(get_response)
        prediction = result.result[-1].doubleValue

        results = []
        results.append(result)

        predictions.append(prediction)

    return predictions, results

input_file = sys.argv[1]
output_file = './prediction_ouput.csv'

df = pd.read_csv(input_file)
df_output = pd.DataFrame()

print "processing ..."
df_output = michelangelo_output(proj_name, model_id, ma_group, df)[0]

print(df_output)
#df_output.to_csv(output_file, index=False)

