My fork of this ports all of the tests (except generators, for which updated tests were generally not implemented anyway) to RSpec. Some other differences:

  * The comprehensive fixture setup is gone, replaced by (sometimes very horribly abused) factories
  * None of the specs are dependent on the activewarehouse-etl library; that dependency is removed
  * The tests run on SQLite in memory by default, so there is no requirement to manage database.yml
  
The remaining files in /test are old generator tests, there for reference until I complete a rewrite of the generators, and the database configuration files for reference until I have Travis CI set up.