-- back compat for old kwarg name
  
  begin;
    
        
            
                
                
            
                
                
            
                
                
            
        
    

    

    merge into LB.stage.fact_consumption_revenue as DBT_INTERNAL_DEST
        using LB.stage.fact_consumption_revenue__dbt_tmp as DBT_INTERNAL_SOURCE
        on (
                    DBT_INTERNAL_SOURCE.contractid = DBT_INTERNAL_DEST.contractid
                ) and (
                    DBT_INTERNAL_SOURCE.productid = DBT_INTERNAL_DEST.productid
                ) and (
                    DBT_INTERNAL_SOURCE.anlagedatum = DBT_INTERNAL_DEST.anlagedatum
                )

    
    when matched then update set
        "CONTRACTID" = DBT_INTERNAL_SOURCE."CONTRACTID","PRODUCTID" = DBT_INTERNAL_SOURCE."PRODUCTID","ANLAGEDATUM" = DBT_INTERNAL_SOURCE."ANLAGEDATUM","VERBRAUCH" = DBT_INTERNAL_SOURCE."VERBRAUCH","UMSATZ" = DBT_INTERNAL_SOURCE."UMSATZ","VALID_FROM" = DBT_INTERNAL_SOURCE."VALID_FROM","VALID_TO" = DBT_INTERNAL_SOURCE."VALID_TO"
    

    when not matched then insert
        ("CONTRACTID", "PRODUCTID", "ANLAGEDATUM", "VERBRAUCH", "UMSATZ", "VALID_FROM", "VALID_TO")
    values
        ("CONTRACTID", "PRODUCTID", "ANLAGEDATUM", "VERBRAUCH", "UMSATZ", "VALID_FROM", "VALID_TO")

;
    commit;