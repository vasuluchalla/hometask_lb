-- back compat for old kwarg name
  
  begin;
    
        
            
                
                
            
                
                
            
                
                
            
        
    

    

    merge into LB.stage.fact_energy_consumption as DBT_INTERNAL_DEST
        using LB.stage.fact_energy_consumption__dbt_tmp as DBT_INTERNAL_SOURCE
        on (
                    DBT_INTERNAL_SOURCE.contractid = DBT_INTERNAL_DEST.contractid
                ) and (
                    DBT_INTERNAL_SOURCE.productid = DBT_INTERNAL_DEST.productid
                ) and (
                    DBT_INTERNAL_SOURCE.createdat = DBT_INTERNAL_DEST.createdat
                )

    
    when matched then update set
        "CONTRACTID" = DBT_INTERNAL_SOURCE."CONTRACTID","PRODUCTID" = DBT_INTERNAL_SOURCE."PRODUCTID","CREATEDAT" = DBT_INTERNAL_SOURCE."CREATEDAT","CONSUMPTION" = DBT_INTERNAL_SOURCE."CONSUMPTION","REVENUE" = DBT_INTERNAL_SOURCE."REVENUE"
    

    when not matched then insert
        ("CONTRACTID", "PRODUCTID", "CREATEDAT", "CONSUMPTION", "REVENUE")
    values
        ("CONTRACTID", "PRODUCTID", "CREATEDAT", "CONSUMPTION", "REVENUE")

;
    commit;