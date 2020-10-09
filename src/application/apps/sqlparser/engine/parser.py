from moz_sql_parser import parse
from .preparer import OraclePreparer


class Parser:
    sql_query: str

    def __init__(self, sql_query: str):
        self.sql_query = sql_query

    def parse(self):
        return parse(self.sql_query)
