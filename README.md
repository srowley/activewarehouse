## ActiveWarehouse

The ActiveWarehouse library provides classes and functions which help with
building data warehouses using Rails. 

This is my fork of the project. I am just a Ruby/Rails hobbyist, but I have a bit of experience with data warehousing, so I had thought about doing something just like this before I found out about it.

I will probably make wholesale changes to the tests and the code. In particular I'd like to move all the tests to RSpec, just because done well, specs can really document your intent beautifully. I also want to add a bit more magic to the generators to make setting up a simple warehouse as easy as it should be. I also don't really like all the fixtures setup, so I might see if that can be done with factories instead.

The rest of this README is an edited version of the original. I am also planning to use this fork in a sample project, but it's not worth getting into that yet.
  
I don't recommend using this fork in your project yet.

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
