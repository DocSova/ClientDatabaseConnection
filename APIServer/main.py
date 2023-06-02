import ast

from flask import Flask
from flask_restful import Api, Resource
from mysql.connector import connect, Error

app = Flask(__name__)
api = Api(app)

actions = [
    {
        "id": 0,
        "query": "SELECT * FROM wanted",
        "mode": 0
    },
    {
        "id": 1,
        "query": "SELECT inf, nickname FROM players WHERE steam_id = '%0'",
        "mode": 0
    },
    {
        "id": 2,
        "query": "SELECT vehicleID, class, garage, fuel, insurance, is_donate FROM vehicles WHERE owners LIKE '__%0%'"
    }
]


class Quote(Resource):
    def get(self, key, data):
        # Разбиваем входные данные, которые разделены символом ;
        parsed_data = data.split(";")
        parsed_return = []
        query_raw = call_sql_query(
            f"SELECT action_id FROM api_calls WHERE query_id = '\"{key}\"'")
        if (query_raw == "Error"):
            return "API Call Error on backend!", 200
        # Проверка что запрос существует в бд
        if not (len(query_raw) == 0):
            # Подбираем action_id из результата запроса
            action_id = query_raw[0][0]
            # Подбираем текст запроса
            action = actions[action_id]['query']

            # Подставляем в запрос данные
            for i in range(len(parsed_data)):
                action = action.replace(f'%{i}', parsed_data[i])

            # Выполняем запрос с подставленными данными
            return_value = call_sql_query(action)

            # Удаляем использованный ключ
            call_sql_query(
                f"DELETE FROM api_calls WHERE query_id = '\"{key}\"'", 1)

            if (return_value == "Error"):
                return "API Call Error on backend!", 200
            # Парсим кавычки, чтобы то что на выходе смогла скушать арма.
            for db_line_index in range(len(return_value)):
                db_line = return_value[db_line_index]
                parsed_line = []
                for element_index in range(len(db_line)):
                    element = db_line[element_index]
                    # int не парсится через literal_eval
                    if not (type(element) == int):
                        parsed_line.append(ast.literal_eval(element))
                    else:
                        parsed_line.append(element)
                parsed_return.append(parsed_line)

        return parsed_return, 200


# mode = 0 - возвращение значения, 1 - обновление значения
def call_sql_query(query, mode=0):
    try:
        with connect(
            host="localhost",
            user="root",
            password="",
            database="zulu"
        ) as connection:
            create_db_query = query
            with connection.cursor() as cursor:
                cursor.execute(create_db_query)
                if (mode == 0):
                    return cursor.fetchall()
                connection.commit()
                return "[]"
    except Error as e:
        print(e)
        return "Error"


api.add_resource(Quote, "/request/<key>/<data>")
if __name__ == '__main__':
    app.run(debug=True)
