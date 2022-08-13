/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[vaccination_trend]
      ,[vaccination_rate]
  FROM [PortfolioProject].[dbo].[PercentVaccinations]