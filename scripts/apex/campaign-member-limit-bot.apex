// Governor limit chaos harness for the Nimbus Trigger Tour movie set.
// This script intentionally exceeds one governor limit per run.
// Expected result: System.LimitException and full transaction rollback.
//
// Pick one mode by editing `limitMode` before running.

String limitMode = 'SOQL_QUERIES';
Integer logEvery = 10;

System.debug(
  'LIMIT-BOT CHAOS :: mode=' +
    limitMode +
    '. A governor-limit failure is expected in this run.'
);

if (limitMode == 'SOQL_QUERIES') {
  Integer queryLimit = Limits.getLimitQueries();

  for (Integer i = 1; i <= queryLimit + 5; i++) {
    [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    if (
      i == 1 ||
      Math.mod(i, logEvery) == 0 ||
      i == queryLimit ||
      i == queryLimit + 1
    ) {
      System.debug(
        'LIMIT-BOT CHAOS [SOQL] :: iteration=' +
          i +
          ', queries=' +
          Limits.getQueries() +
          '/' +
          queryLimit
      );
    }
  }
} else if (limitMode == 'DML_STATEMENTS') {
  Account limitBotAccount = new Account(
    Name = 'LIMIT-BOT DML anchor ' + Datetime.now().getTime()
  );
  insert limitBotAccount;

  Integer dmlStatementLimit = Limits.getLimitDmlStatements();
  for (Integer i = 1; i <= dmlStatementLimit + 5; i++) {
    limitBotAccount.Description = 'LIMIT-BOT DML statement tick #' + i;
    update limitBotAccount;
    if (
      i == 1 ||
      Math.mod(i, logEvery) == 0 ||
      i == dmlStatementLimit ||
      i == dmlStatementLimit + 1
    ) {
      System.debug(
        'LIMIT-BOT CHAOS [DML statements] :: iteration=' +
          i +
          ', dml statements=' +
          Limits.getDmlStatements() +
          '/' +
          dmlStatementLimit
      );
    }
  }
} else if (limitMode == 'DML_ROWS') {
  Integer dmlRowsLimit = Limits.getLimitDmlRows();
  Integer rowsPerInsert = 200;
  Integer targetRows = dmlRowsLimit + 200;
  Integer totalRowsInserted = 0;

  while (totalRowsInserted < targetRows) {
    List<Account> batchAccounts = new List<Account>();
    for (Integer i = 0; i < rowsPerInsert; i++) {
      Integer sequence = totalRowsInserted + i + 1;
      batchAccounts.add(
        new Account(Name = 'LIMIT-BOT DML row #' + String.valueOf(sequence))
      );
    }

    insert batchAccounts;
    totalRowsInserted += batchAccounts.size();

    if (
      totalRowsInserted == rowsPerInsert ||
      Math.mod(totalRowsInserted, 1000) == 0 ||
      totalRowsInserted >= dmlRowsLimit
    ) {
      System.debug(
        'LIMIT-BOT CHAOS [DML rows] :: inserted rows=' +
          totalRowsInserted +
          ', dml rows=' +
          Limits.getDmlRows() +
          '/' +
          dmlRowsLimit
      );
    }
  }
} else {
  System.debug(
    'LIMIT-BOT CHAOS :: unknown mode "' +
      limitMode +
      '". Use SOQL_QUERIES, DML_STATEMENTS, or DML_ROWS.'
  );
}
