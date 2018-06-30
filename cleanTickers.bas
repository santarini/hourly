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

Call createTemplate

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

If tickerRangeLen > 100 Then
j = 1
While j < qtyHundredBatches
    
    ReDim tickers(1 To 100) As Variant
    
    'push a hundred values into the array
    For i = 1 To 100 Step 1
        Rng1.Select
        tickers(i) = Selection.Value
        Set Rng1 = Rng1.Offset(1, 0)
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
        Set Rng2 = Rng2.Offset(1, 0)
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
        Set Rng2 = Rng2.Offset(1, 0)
    Next

End If
If tickerRangeLen <= 100 Then
    
    'redefine tickers
    ReDim tickers(1 To tickerRangeLen) As Variant

    'push values into an array
    For i = 1 To tickerRangeLen Step 1
        Rng1.Select
        tickers(i) = Selection.Value
        Set Rng1 = Rng1.Offset(1, 0)
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
        Set Rng2 = Rng2.Offset(1, 0)
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
        .SplitRow = 1
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
        Rng2.Offset(0, 8).Value = Format(latestVolume, "#,##0")
        Rng2.Offset(0, 9).Value = Format(marketcap, "Currency")
        Rng2.Offset(0, 10).Value = Format(sharesOutstanding, "#,##0")
        Rng2.Offset(0, 11).Value = Format(float, "#,##0")

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
Range("I1").Value = "Latest Volume"
Range("J1").Value = "Marketcap"
Range("K1").Value = "Shares Outstanding"
Range("L1").Value = "Shares Float"



End Function
