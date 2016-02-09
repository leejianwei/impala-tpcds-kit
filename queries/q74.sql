-- start query 74 in stream 0 using template query74.tpl
with year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       --,stddev_samp(ss_net_paid) year_total
       ,cast(stddev_samp(ss_net_paid) as int) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk between 2451545 and 2452275
   and ss_sold_date_sk = d_date_sk
   and d_year in (2000,2000+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,cast(stddev_samp(ws_net_paid) as int) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk  between 2451545 and 2452275
   and ws_sold_date_sk = d_date_sk
   and d_year in (2000,2000+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
         )
 select
        t_s_secyear.customer_id col1, t_s_secyear.customer_first_name col2, t_s_secyear.customer_last_name col3 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.sale_type = 's'
         and t_w_firstyear.sale_type = 'w'
         and t_s_secyear.sale_type = 's'
         and t_w_secyear.sale_type = 'w'
         and t_s_firstyear.year = 2000
         and t_s_secyear.year = 2000+1
         and t_w_firstyear.year = 2000
         and t_w_secyear.year = 2000+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
 order by 1,3,2
 limit 100;
-- end query 74 in stream 0 using template query74.tpl
