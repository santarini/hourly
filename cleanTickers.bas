Sub stockScrapeAlpha()

'define ticker range

Dim tickerRange As Range

Cells.Find(What:="Ticker", After:=ActiveCell, LookIn:=xlFormulas, LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext, MatchCase:=True, SearchFormat:=False).Activate
Selection.Offset(1, 0).Select
Range(Selection, Selection.End(xlDown)).Select

Set tickerRange = Selection
'count the number of cells in tickerRange and store that in an int

Dim tickerRangeLen As Integer
tickerRangeLen = tickerRange.Cells.Count

'Prompt count, if wrong you have a chance to cnacel routine.
 
Dim strtMsg As String
strtMsg = MsgBox("Stock Scrape found " & tickerRangeLen & " tickers", vbOKCancel, "Ticker Count")
Select Case strtMsg
Case 2
    Exit Sub
Case 1

'Perform this in the background, or not it's totally your choice

Application.ScreenUpdating = False
Application.DisplayAlerts = False

'define a timer, and start the timer

Dim StartTime As Double
Dim SecondsElapsed As Double
  StartTime = Timer

'define the top two ranges that both identify the first cell in the column

Dim Rng1 As Range
Dim Rng2 As Range
Set Rng1 = tickerRange.Cells(1, 1)
Set Rng2 = tickerRange.Cells(1, 1)

'define a batch variable

Dim batch As String

'define an array for the tickers

Dim tickers() As Variant

'create a JSON object
Dim Json As Object

'create a dicitonary
Dim Dict As New Dictionary
Dict.CompareMode = CompareMethod.TextCompare

'The max number of tickers per request is 100
'SOOOO we need to define some extra stuff if you happen to be fetching more than 100 tickers

Dim qtyHundredBatches As Integer
Dim remainder As Integer
Dim i As Integer
Dim j As Integer

qtyHundredBatches = tickerRangeLen / 100
remainder = tickerRangeLen Mod 100

If tickerRangeLen >= 100 Then
j = 1
While j < qtyHundredBatches
    
    ReDim tickers(1 To 100) As Variant
    
    'push a hundred values into the array
    For i = 1 To 100 Step 1
        Rng1.Select
        tickers(i) = Selection.Value
        Rng1.Offset(1, 0).Select
        Set Rng1 = ActiveCell
    Next
    
    'join those hundred into a single string string
    batch = Join(tickers, ",")
    
    'fetch the url
    Set MyRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
    MyRequest.Open "GET", "https://api.iextrading.com/1.0/stock/market/batch?symbols=" & batch & "&types=company,quote,stats,financials,earnings,dividends"
    MyRequest.Send
    
    'create a JSON object
    Set Json = JsonConverter.ParseJson(MyRequest.ResponseText)
    
    'paste the JSON values into spreasheet
    
    For i = 1 To 100 Step 1
        Dict("A") = Rng2.Value
        Call iexTradingJSON(Dict, Rng1, Rng2, Json)
        Set Rng2 = ActiveCell
    Next
    j = j + 1
Wend
    'redefine tickers
    ReDim tickers(1 To remainder) As Variant

    'push a hundred values into an array
    For i = 1 To remainder Step 1
        Rng1.Select
        tickers(i) = Selection.Value
        Rng1.Offset(1, 0).Select
        Set Rng1 = ActiveCell
    Next
    
    'join those hundred into a single string string
    batch = Join(tickers, ",")
    
    'fetch the url
    Set MyRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
    MyRequest.Open "GET", "https://api.iextrading.com/1.0/stock/market/batch?symbols=" & batch & "&types=company,quote,stats,financials,earnings,dividends"
    MyRequest.Send
    
    'Set JSON
    
    Set Json = JsonConverter.ParseJson(MyRequest.ResponseText)
    
    'paste the JSON values into spreasheet
    
    For i = 1 To remainder Step 1
        Dict("A") = Rng2.Value
        Call iexTradingJSON(Dict, Rng1, Rng2, Json)
        Set Rng2 = ActiveCell
    Next

End If
If tickerRangeLen < 100 Then
    
    'redefine tickers
    ReDim tickers(1 To tickerRangeLen) As Variant

    'push values into an array
    For i = 1 To tickerRangeLen Step 1
        Rng1.Select
        tickers(i) = Selection.Value
        Rng1.Offset(1, 0).Select
        Set Rng1 = ActiveCell
    Next
    
    'join those hundred into a single string string
    batch = Join(tickers, ",")
    
    'fetch the url
    Set MyRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
    MyRequest.Open "GET", "https://api.iextrading.com/1.0/stock/market/batch?symbols=" & batch & "&types=company,quote,stats,financials,earnings,dividends"
    MyRequest.Send
    
    Set Json = JsonConverter.ParseJson(MyRequest.ResponseText)
    
    'paste the JSON values into spreasheet
    
    For i = 1 To tickerRangeLen Step 1
        Dict("A") = Rng2.Value
        Call iexTradingJSON(Dict, Rng1, Rng2, Json)
        Set Rng2 = ActiveCell
    Next
End If

'resize some columns
Cells.Select
Selection.Columns.AutoFit
Columns("B:B").Select
Selection.ColumnWidth = 50
Columns("F:F").Select
Selection.ColumnWidth = 30

'turn these things on to properly freeze panes
Application.ScreenUpdating = True
Application.DisplayAlerts = True

'freeze panes
Range("A1").Select
    With ActiveWindow
        .SplitColumn = 1
        .SplitRow = 2
    End With
ActiveWindow.FreezePanes = True

SecondsElapsed = Round(Timer - StartTime, 2)

'Notify user in seconds
Dim tickersPerSec As Single

tickersPerSec = (tickerRangeLen / SecondsElapsed)
  MsgBox "This code ran successfully in " & SecondsElapsed & " seconds" & vbCrLf & "Approximately " & tickersPerSec & " per second", vbInformation
End Select
End Sub


Public Function iexTradingJSON(Dict As Dictionary, Rng1 As Range, Rng2 As Range, Json As Object)

    Dim companyName, exchange, sector, industry, CEO, issueType, dividendType As Variant
    Dim latestPrice, openPrice, closePrice, low, high, change, changePercent, latestVolume, avgTotalVolume, week52Low, week52High, day50MovingAvg, day200MovingAvg, day5ChangePercent, month1ChangePercent, month3ChangePercent, month6ChangePercent, ytdChangePercent, year1ChangePercent, year3ChangePercent, year5ChangePercent, beta, marketcap, sharesOutstanding, float, revenue, revenuePerShare, revenuePerEmployee, EBITDA, grossProfit, profitMargin, cash, debt, returnOnEquity, returnOnAssets, returnOnCapital, peRatio, peRatioLow, peRatioHigh, priceToSales, priceToBook, shortRatio, costOfRevenue, opeartingRevenue, totalRevenue, opeartingIncome, netIncome, researchAndDevelopment, opeartingExpenses, currentAssets, totalAssets, totalLiabilities, currentCash, currentDebt, totalCash, totalDebt, shareholderEquity, cashChange, cashFlow, operatingGainsLosses, amount, dividendRate, dividendYield As Variant
    Dim exDate, paymentDate, declaredDate, recordDate, reportDate, latestTime, website, description, latestEPSDate As Variant
    
    On Error GoTo Handler:
        companyName = Json(Dict.Item("A"))("company")("companyName")
        website = Json(Dict.Item("A"))("company")("website")
        description = Json(Dict.Item("A"))("company")("description")
        exchange = Json(Dict.Item("A"))("company")("exchange")
        sector = Json(Dict.Item("A"))("company")("sector")
        industry = Json(Dict.Item("A"))("company")("industry")
        CEO = Json(Dict.Item("A"))("company")("CEO")
        issueType = Json(Dict.Item("A"))("company")("issueType")
        latestTime = Json(Dict.Item("A"))("quote")("latestTime")
        latestPrice = Json(Dict.Item("A"))("quote")("latestPrice")
        latestVolume = Json(Dict.Item("A"))("quote")("latestVolume")
        marketcap = Json(Dict.Item("A"))("stats")("marketcap")
        sharesOutstanding = Json(Dict.Item("A"))("stats")("sharesOutstanding")
        float = Json(Dict.Item("A"))("stats")("float")

        Rng2.Offset(0, 1).Value = companyName
        Rng2.Offset(0, 2).Value = exchange
        Rng2.Offset(0, 3).Value = sector
        Rng2.Offset(0, 4).Value = industry
        Rng2.Offset(0, 5).Value = CEO
        Rng2.Offset(0, 6).Value = issueType
        Rng2.Offset(0, 7).Value = Format(latestPrice, "Currency")
        Rng2.Offset(0, 14).Value = Format(latestVolume, "#,##0")
        Rng2.Offset(0, 16).Value = Format(marketcap, "Currency")
        Rng2.Offset(0, 17).Value = Format(sharesOutstanding, "#,##0")
        Rng2.Offset(0, 18).Value = Format(float, "#,##0")

ExitErrorPoint:
Exit Function

Handler:
        reportDate = ""
        totalRevenue = ""
        costOfRevenue = ""
        grossProfitQTR = ""
        operatingRevenue = ""
        operatingIncome = ""
        netIncome = ""
        researchAndDevelopment = ""
        operatingExpense = ""
        currentAssets = ""
        totalAssets = ""
        totalLiabilities = ""
        currentCash = ""
        currentDebt = ""
        totalCash = ""
        totalDebt = ""
        shareholderEquity = ""
        cashChange = ""
        cashFlow = ""
        operatingGainsLosses = ""
Resume ExitErrorPoint
                      
End Function
Function createTemplate()

Range("B1").Value = "Company Name"
Range("C1").Value = "Exchange "
Range("D1").Value = "Sector"
Range("E1").Value = "Industry"
Range("F1").Value = "CEO"
Range("G1").Value = "Issue Type"
Range("H1").Value = "Latest Price"
Range("I1").Value = "Open Price"
Range("J1").Value = "Close Price"
Range("K1").Value = "Low"
Range("L1").Value = "High"
Range("M1").Value = "Change"
Range("N1").Value = "Change Percent"
Range("O1").Value = "Latest Volume"
Range("P1").Value = "Beta"
Range("Q1").Value = "Marketcap"
Range("R1").Value = "Shares Outstanding"
Range("S1").Value = "Float"
Range("T1").Value = "Avg Total Volume"
Range("U1").Value = "Week 52 Low"
Range("V1").Value = "Week 52 High"
Range("W1").Value = "50 Day Moving Avg"
Range("X1").Value = "200 Day Moving Avg"
Range("Y1").Value = "5 Day Change Percent"
Range("Z1").Value = "1 Month Change Percent"
Range("AA1").Value = "3 Month Change Percent"
Range("AB1").Value = "6 Month Change Percent"
Range("AC1").Value = "YTD Change Percent"
Range("AD1").Value = "1 Year Change Percent"
Range("AE1").Value = "2 Year Change Percent"
Range("AF1").Value = "5 Year Change Percent"
Range("AG1").Value = "Revenue"
Range("AH1").Value = "Revenue Per Share"
Range("AI1").Value = "Revenue Per Employee"
Range("AJ1").Value = "Gross Profit"
Range("AK1").Value = "Profit Margin"
Range("AL1").Value = "EBITDA"
Range("AM1").Value = "Cash"
Range("AN1").Value = "Debt"
Range("AO1").Value = "Return On Equity"
Range("AP1").Value = "Return On Assets"
Range("AQ1").Value = "Return On Capital"
Range("AR1").Value = "P/E Ratio"
Range("AS1").Value = "P/E Ratio Low"
Range("AT1").Value = "P/E Ratio High"
Range("AU1").Value = "Price To Sales"
Range("AV1").Value = "Price To Book"
Range("AW1").Value = "Short Ratio"
Range("AX1").Value = "Total Revenue"
Range("AY1").Value = "Cost Of Revenue"
Range("AZ1").Value = "Gross Profit"
Range("BA1").Value = "Operating Revenue"
Range("BB1").Value = "Operating Income"
Range("BC1").Value = "Net Income"
Range("BD1").Value = "Research and Development"
Range("BE1").Value = "Total Operating Expenses"
Range("BF1").Value = "Current Assets"
Range("BG1").Value = "Total Assets"
Range("BH1").Value = "Total Liabilities"
Range("BI1").Value = "Current Cash"
Range("BJ1").Value = "Current Debt"
Range("BK1").Value = "Total Cash"
Range("BL1").Value = "Total Debt"
Range("BM1").Value = "Shareholder Equity"
Range("BN1").Value = "Cash Change"
Range("BO1").Value = "Cash Flow"
Range("BP1").Value = "Operating Gains Losses"
Range("BQ1").Value = "Amount"
Range("BR1").Value = "Dividend Type"
Range("BS1").Value = "Dividend Rate"
Range("BT1").Value = "Dividend Yield"
Range("BU1").Value = "Ex Date"
Range("BV1").Value = "Payment Date"
Range("BW1").Value = "Declared Date"
Range("BX1").Value = "Record Date"
Range("BY1").Value = "Qualified"
Range("A1:BY1").Select
Selection.Font.Bold = True
Range("A1").Select
Selection.EntireRow.Insert
Range("A1").Select
Range("A1").Value = "Details"
Selection.AutoFill Destination:=Range("A1:G1"), Type:=xlFillDefault
Range("H1").Select
Range("H1").Value = "Current Quote"
Selection.AutoFill Destination:=Range("H1:S1"), Type:=xlFillDefault
Range("T1").Select
Range("T1").Value = "Historical Quote"
Selection.AutoFill Destination:=Range("T1:AF1"), Type:=xlFillDefault
Range("AG1").Select
Range("AG1").Value = "Annual"
Selection.AutoFill Destination:=Range("AG1:AW1"), Type:=xlFillDefault
Range("AX1").Select
Range("AX1").Value = "Quarter"
Selection.AutoFill Destination:=Range("AX1:BP1"), Type:=xlFillDefault
Range("A1:BY1").Select
Selection.Font.Bold = True


End Function
