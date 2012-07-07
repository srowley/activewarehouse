## ActiveWarehouse

The ActiveWarehouse library provides classes and functions which help with
building data warehouses using Rails.

[![Build Status](https://secure.travis-ci.org/srowley/activewarehouse.png?branch=master)](http://travis-ci.org/srowley/activewarehouse)

This is my fork of the project. I am just a Ruby/Rails hobbyist, but I have a bit of experience with data warehousing, so I had thought about doing something just like this before I found out about it.

I'm making wholesale changes to the tests. The tests have been ported to RSpec and the fixture replaced with factories, among other things. Mainly I just wanted to learn more by doing with RSpec and FactoryGirl, but I also think that done right those tools help you document your intent beautifully (which is not to call what I've accomplished there beauty, by any means), and the port gave me a nice overview of the codebase at the same time. There were some other test changes too, see the README in the spec directory.

Next I think I'll try to get a very simple example working - links will be here when I have them. Then on to a few improvements to the generators, hopefully.

I don't recommend using this fork in your project yet if ever because this is just a for-fun project for me for now.

The rest of this README is an edited version of the original.

## Generators

ActiveWarehouse comes with several generators:

```
rails g active_warehouse:fact Sales
``` 

Creates a SalesFact class and a sales_facts table.
 
```
rails g active_warehouse:dimension Region
```

Creates a RegionDimension class and a region_dimension table.
 
```
rails g active_warehouse:cube RegionalSales
``` 

Creates a RegionalSalesCube class.
   
```
rails g active_warehouse:bridge CustomerHierarchy
```

Creates a CustomerHierarchyBridge class.
   
```
rails g active_warehouse:dimension_view OrderDate Date
```
  
Creates an OrderDateDimension class which is represented by a view on top of the DateDimension.
   
## Naming Conventions

* **Fact classes** and tables follow the typical Rails rules: classes are singular and tables are pluralized. Both the class and table name are suffixed by "_fact".

* **Dimension classes** and tables are both singular. Both the class name and the table name are suffixed by "_dimension".

* **Cube classes** are singular. If a cube table is created it will also be singular.

* **Bridge classes** and tables are both singular. Both the class name and the table name are suffixed by "_bridge".

* **Dimension View** classes are singular. The underlying data structure is a view on top of an existing dimension. Both the class name and the view name are suffixed by "_dimension"
  
## ETL

The ActiveWarehouse plugin does not directly handle Extract-Transform-Load
processes, however the ActiveWarehouse ETL gem can help.

## Tutorial

A [somewhat out-of-date tutorial](http://web.archive.org/web/20070722230250/http://anthonyeden.com/2006/12/20/activewarehouse-example-with-rails-svn-logs) for ActiveWarehouse is available.
