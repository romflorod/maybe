# README: Implementación de Gestión de Tipos de Cambio

Este documento describe cómo se implementaron las funcionalidades relacionadas con la gestión de tipos de cambio en la aplicación. A continuación, se detallan los pasos realizados para cumplir con los requisitos.

---

## 1. **Almacenamiento de Datos**
Se creó un modelo para guardar el histórico de tipos de cambio entre monedas.

### Archivo: historical_exchange_rate.rb
- **Campos requeridos**:
  - `from_currency`: Moneda de origen.
  - `to_currency`: Moneda de destino.
  - `rate`: Tasa de cambio.
  - `date`: Fecha del tipo de cambio.
- **Validaciones**:
  - Todos los campos son obligatorios (`presence: true`).
  - La tasa de cambio (`rate`) debe ser un número mayor a 0.
- **Índices**:
  - Se pueden agregar índices en la base de datos para optimizar consultas frecuentes, como búsquedas por `from_currency`, `to_currency` y `date`.

Código del modelo:
```ruby
class HistoricalExchangeRate < ApplicationRecord
  validates :from_currency, :to_currency, :rate, :date, presence: true
  validates :rate, numericality: { greater_than: 0 }
end
```

---

## 2. **Automatización**
Se desarrolló un job que se ejecuta diariamente para obtener y almacenar tipos de cambio.

### Archivos:
- **`fetch_exchange_rates_job.rb`**:
  - Este job utiliza el proveedor de tipos de cambio existente para obtener los datos.
  - Los datos obtenidos se guardan en el modelo `HistoricalExchangeRate`.
  - Se implementó manejo básico de errores para registrar problemas en los logs.

Código del job:
```ruby
class FetchExchangeRatesJob < ApplicationJob
  queue_as :default

  def perform
    currencies = %w[USD EUR GBP JPY]
    start_date = Date.yesterday
    end_date = Date.current

    currencies.combination(2).each do |from, to|
      begin
        rates = ExchangeRate.fetch_rates_from_provider(from: from, to: to, start_date: start_date, end_date: end_date)
        rates.each do |rate_data|
          HistoricalExchangeRate.create!(
            from_currency: rate_data.from_currency,
            to_currency: rate_data.to_currency,
            rate: rate_data.rate,
            date: rate_data.date
          )
        end
      rescue StandardError => e
        Rails.logger.error("Error fetching rates for #{from} to #{to}: #{e.message}")
      end
    end
  end
end
```

- **`fetch_exchange_rates.bat`**:
  - Script para ejecutar el job diariamente usando el programador de tareas del sistema operativo.

Código del script:
```bat
@echo off
cd d:\pt\maybe
rails runner "FetchExchangeRatesJob.perform_later"
```

---

## 3. **API**
Se creó un endpoint para devolver el histórico de tipos de cambio.

### Archivos:
- **Ruta**:
  - Se añadió la ruta en `routes.rb`:
    ```ruby
    resources :historical_exchange_rates, only: [:index]
    ```

- **Controlador**:
  - Se implementó el controlador `HistoricalExchangeRatesController` para manejar las solicitudes.
  - Permite filtrar por rango de fechas y pares de monedas.
  - Implementa paginación básica.

Código del controlador:
```ruby
class HistoricalExchangeRatesController < ApplicationController
  def index
    rates = HistoricalExchangeRate.all

    if params[:start_date].present? && params[:end_date].present?
      rates = rates.where(date: params[:start_date]..params[:end_date])
    end

    if params[:from_currency].present? && params[:to_currency].present?
      rates = rates.where(from_currency: params[:from_currency], to_currency: params[:to_currency])
    end

    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
    rates = rates.page(page).per(per_page)

    render json: rates
  end
end
```

---

## 4. **Tests**
Se escribieron tests para el modelo, el job y el endpoint de la API.

### Archivos:
- **Modelo**:
  - Se probaron las validaciones del modelo `HistoricalExchangeRate`.
- **Job**:
  - Se verificó que el job guarda correctamente los datos y maneja errores.
- **API**:
  - Se probaron las rutas y la funcionalidad del endpoint.

Ejemplo de test para el job:
```ruby
require "test_helper"

class FetchExchangeRatesJobTest < ActiveJob::TestCase
  test "should fetch and save exchange rates" do
    mock_rates = [
      OpenStruct.new(from_currency: "USD", to_currency: "EUR", rate: 0.85, date: Date.yesterday),
      OpenStruct.new(from_currency: "USD", to_currency: "EUR", rate: 0.86, date: Date.current)
    ]

    ExchangeRate.stub :fetch_rates_from_provider, mock_rates do
      assert_difference "HistoricalExchangeRate.count", 2 do
        FetchExchangeRatesJob.perform_now
      end
    end
  end
end
```

---

## 5. **Vista**
Se creó una vista para mostrar los tipos de cambio y permitir la selección de pares de monedas.

### Archivo: index.html.erb
- Permite seleccionar el par de monedas y el rango de fechas.
- Muestra los resultados en una tabla.
- Integra los estilos de la aplicación.

Código de la vista:
```erb
<!-- filepath: d:\pt\maybe\app\views\exchange_rates\index.html.erb -->
<%= styled_form_with url: exchange_rates_path, method: :get do |f| %>
  <%= f.text_field :from_currency, placeholder: "e.g., USD" %>
  <%= f.text_field :to_currency, placeholder: "e.g., EUR" %>
  <%= f.date_field :start_date, value: @start_date %>
  <%= f.date_field :end_date, value: @end_date %>
  <%= f.submit "Filter" %>
<% end %>

<% if @exchange_rates.any? %>
  <table>
    <thead>
      <tr>
        <th>Date</th>
        <th>Rate</th>
      </tr>
    </thead>
    <tbody>
      <% @exchange_rates.each do |rate| %>
        <tr>
          <td><%= rate.date %></td>
          <td><%= rate.rate %></td>
        </tr>
      <% end %>
    </tbody>
  </table>
<% else %>
  <p>No exchange rates found for the selected criteria.</p>
<% end %>
```

---

## Resumen
- **Modelo:** `HistoricalExchangeRate` para almacenar los datos.
- **Automatización:** Job `FetchExchangeRatesJob` para obtener y guardar tipos de cambio diariamente.
- **API:** Endpoint para consultar el histórico de tipos de cambio con filtros y paginación.
- **Vista:** Interfaz para visualizar y filtrar los tipos de cambio.
- **Tests:** Cobertura para modelo, job y API.