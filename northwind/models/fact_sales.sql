with stg_orders as (
    select * from {{ source('northwind', 'Orders') }}
),

stg_order_details as (
    select * from {{ source('northwind', 'Order_Details') }}
)

select
    od.orderid,
    {{ dbt_utils.generate_surrogate_key(['o.customerid']) }} as customerkey,
    {{ dbt_utils.generate_surrogate_key(['o.employeeid']) }} as employeekey,
    replace(to_date(o.orderdate)::varchar, '-', '')::int as orderdatekey,
    {{ dbt_utils.generate_surrogate_key(['od.productid']) }} as productkey,
    od.quantity,
    od.quantity * od.unitprice as extendedpriceamount,
    od.quantity * od.unitprice * od.discount as discountamount,
    od.quantity * od.unitprice * (1 - od.discount) as soldamount
from stg_order_details od
join stg_orders o
    on od.orderid = o.orderid