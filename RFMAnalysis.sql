WITH CustomerSalesOrders AS
(
    SELECT FIS.CustomerKey
          ,FIS.SalesOrderNumber
          ,SUM(SalesAmount) AS SalesAmount
          ,MAX(OrderDate) AS OrderDate
    FROM FactInternetSales FIS
    GROUP BY FIS.CustomerKey, FIS.SalesOrderNumber
),
CustomerSalesOrderHistory AS
(
    SELECT CSO.CustomerKey
          ,COUNT(*) AS SalesOrderCount
          ,SUM(CSO.SalesAmount) AS SalesAmount
          ,DATEDIFF(DAY, MAX(CSO.OrderDate), CURRENT_TIMESTAMP) AS ElapsedDaysToMostRecentOrder
    FROM CustomerSalesOrders CSO
    GROUP BY CSO.CustomerKey
),
RFMAnalysis AS
(
    SELECT CSOH.CustomerKey
          ,NTILE(10) OVER (ORDER BY CSOH.ElapsedDaysToMostRecentOrder DESC) AS RecencyScore
          ,NTILE(10) OVER (ORDER BY CSOH.SalesOrderCount ASC) AS FrequencyScore
          ,NTILE(10) OVER (ORDER BY CSOH.SalesAmount ASC) AS MonetaryScore
    FROM CustomerSalesOrderHistory CSOH
)
SELECT RFM.CustomerKey
      ,RFM.RecencyScore
      ,RFM.FrequencyScore
      ,RFM.MonetaryScore
FROM RFMAnalysis RFM
WHERE RFM.RecencyScore >= 8 AND
      RFM.FrequencyScore >= 8 AND
      RFM.MonetaryScore >= 8
ORDER BY RFM.CustomerKey ASC;
