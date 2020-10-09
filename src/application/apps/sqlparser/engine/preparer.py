from re import sub, compile
from abc import abstractmethod


class Preparer:
    """
    Prepare query to parse
    replace \n, comments etc.
    """

    @abstractmethod
    def delete_comments(self) -> str:
        pass


class OraclePreparer(Preparer):
    """
    Normal oracle query(delete "-- bla bla", "/* bla bla */")
    \n and \r
    """
    sql_query: str
    __normalize_query: str

    def __init__(self, query_string: str = ''):
        self.sql_query = query_string

    def delete_comments(self) -> str:
        sql_string: str = self.sql_query
        # Pattern to replace oracle multiline comments(/* bla bla bla */)
        multiline_comment_pattern = compile("/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/")
        sql_string = sub(multiline_comment_pattern, '', sql_string)

        # Pattern to replace one-line oracle comments (-- bla bla bla)
        one_line_comment_pattern = compile("(--)+.*\n")
        sql_string = sub(one_line_comment_pattern, '', sql_string)
        return sql_string

    @property
    def get_normalize_query(self) -> str:
        self.__normalize_query = self.delete_comments()
        # replace end-line symbols
        self.__normalize_query = self.__normalize_query.replace('\n', '').replace('\r', '')
        self.__normalize_query = sub(" +", " ", self.__normalize_query)
        return self.__normalize_query
