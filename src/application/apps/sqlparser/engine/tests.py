from .preparer import OraclePreparer


def test_simple_query():

    with open('./querys/SIMPLE_SQL.sql') as sql_scr, open('./querys/SIMPLE_SQL__NORMAL.sql') as normal_sql_src:
        sql_txt = sql_scr.read()
        normal_sql_txt = normal_sql_src.read()
        my_preparer = OraclePreparer(sql_txt)
        assert my_preparer.get_normalize_query == str.strip(normal_sql_txt)

