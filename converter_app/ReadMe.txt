Testing: This app has been tested only on a iPhone simulator.


The Currency Conversion App is a simple and intuitive mobile application 
that allows users to convert currency values between predefined 
currencies. 


Features


○ Currency Conversion


    Functionality:
        Input the amount to convert.
        Select the source currency (e.g., EUR).
        Select the target currency (e.g., USD).
        Conversion is performed automatically and displayed instantly.
    Currencies Supported:
        EUR (Euro)
        USD (United States Dollar)
        SEK (Swedish Krona)
        GBP (British Pound Sterling)
        CNY (Chinese Yuan)
        JPY (Japanese Yen)
        KRW (South Korean Won)

○ View Conversion Rates


    Functionality:
        Navigate to the "Conversion Rates" page from the main page.
        View the list of conversion rates in a user-friendly format.
        Each rate is displayed as Source Currency → Target Currency: 
Rate.
    Exchange Rates:
        The app uses constant, predefined exchange rates, such as:
            EUR to USD: 1.1
            EUR to SEK: 11.0
            EUR to GBP: 0.85
            Other rates are similarly listed.

------------------------------------------------------------------------------------

Technical Features
○ Responsive Design

    Supports both portrait and landscape orientations to ensure usability 
across all device layouts.

○ Navigation

    Provides seamless navigation between the main page and the conversion 
rates page using named routes:
        /: Main currency conversion page.
        /rates: Conversion rates page.

○ Real-Time Updates

    Conversion results are displayed in real-time as users input the 
amount or change currencies.

○ User-Friendly Interface

    Clean and intuitive interface with dropdown menus for currency 
selection.
    Instantaneous feedback on input changes for a smooth user experience.

------------------------------------------------------------------------------------

Code Structure
Files and Directories

    ○ main.dart: Application entry point. Contains route definitions and 
initializes the app.
    ○ pages/main_page.dart: Implements the main currency conversion 
functionality.
    ○ pages/conversion_rates_page.dart: Displays a list of all predefined 
exchange rates.
    ○ utils/exchange_rates.dart: Contains constant exchange rates used for 
conversion.


------------------------------------------------------------------------------------

Future Enhancements
Planned Updates

    Real-Time Data:
        Replace constant exchange rates with live rates fetched from an 
API.
    Enhanced Features:
        Add a feature to view historical exchange rate trends.
        Support for more currencies and custom exchange rate 
configurations.
    User Customization:
        Save favorite currency pairs for quick access.
        Add dark mode support for better usability in low-light 
conditions.
