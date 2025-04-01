@echo off
cd d:\pt\maybe
rails runner "FetchExchangeRatesJob.perform_later"