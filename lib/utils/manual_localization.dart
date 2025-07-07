// Manual localization utility for English and Luganda

const Map<String, Map<String, String>> kTranslations = {
  'appTitle': {'en': 'Job Pop', 'lg': 'Job Pop'},
  'login': {'en': 'Login', 'lg': 'Yingira'},
  'signup': {'en': 'Sign Up', 'lg': 'Wewandiise'},
  'chooseLanguage': {'en': 'Choose Language', 'lg': 'Londa Olulimi'},
  'profile': {'en': 'Profile', 'lg': 'Bwino wo'},
  'logout': {'en': 'Logout', 'lg': 'Vamu'},
  'findAJobAnywhere': {
    'en': 'Find a job anywhere',
    'lg': 'Zuula omulimu wonna'
  },
  'chooseLocation': {'en': 'Choose location', 'lg': 'Londa ekifo'},
  'pleaseSelectJobCategory': {
    'en': 'Please select a job category',
    'lg': 'Londa ekika ky\'omulimu'
  },
  'jobCategory': {'en': 'Job Category *', 'lg': 'Ekika ky\'Omulimu *'},
  'search': {'en': 'SEARCH', 'lg': 'NOONYEREZA'},
  'loginWithPhone': {
    'en': 'Or login with phone/username',
    'lg': 'Oba yingira n\'essimu/erinnya'
  },
  'usernameOrPhone': {'en': 'Username or Phone', 'lg': 'Erinnya oba Essimu'},
  'usernameOrPhoneRequired': {
    'en': 'Username or phone is required',
    'lg': 'Erinnya oba Essimu yetaagisa'
  },
  'password': {'en': 'Password', 'lg': 'Pasiwaadi'},
  'passwordRequired': {
    'en': 'Password is required',
    'lg': 'Pasiwaadi yetaagisa'
  },
  'forgotPassword': {'en': 'Forgot Password?', 'lg': 'Welabidde Pasiwaadi?'},
  'createNewAccount': {'en': 'Create New Account', 'lg': 'Kola Akawunti Empya'},
  'createAccount': {'en': 'Create Account', 'lg': 'Kola Akawunti'},
  'createNewUser': {'en': 'Create New User', 'lg': 'Kola Omukozesa Omupya'},
  'fullName': {'en': 'Full Name *', 'lg': 'Erinnya lyo Lyona *'},
  'pleaseFillInYourFullName': {
    'en': 'Please fill in your full name',
    'lg': 'Jjuzza erinnya lyo lyonna'
  },
  'country': {'en': 'Country *', 'lg': 'Ggwanga *'},
  'pleaseSelectCountry': {
    'en': 'Please select a country',
    'lg': 'Londa eggwanga'
  },
  'username': {'en': 'Username *', 'lg': 'Erinnya Omukozesa *'},
  'pleaseEnterYourUsername': {
    'en': 'Please enter your username',
    'lg': 'Yingiza erinnya ly\'omukozesa'
  },
  'phone': {'en': 'Phone *', 'lg': 'Ssimu *'},
  'pleaseEnterYourPhone': {
    'en': 'Please enter your phone',
    'lg': 'Yingiza essimu yo'
  },
  'passwordField': {'en': 'Password *', 'lg': 'Pasiwaadi *'},
  'pleaseEnterYourPassword': {
    'en': 'Please enter your password',
    'lg': 'Yingiza pasiwadi yo'
  },
  'submit': {'en': 'Submit', 'lg': 'Twala'},
  'signupAsCompany': {
    'en': 'Signup as a Company Instead',
    'lg': 'Wandiika nga Kampuni'
  },
  'signInWithGoogle': {
    'en': 'Sign in with Google',
    'lg': 'Yingira nga okozesa Google'
  },
  'signUpWithGoogle': {
    'en': 'Sign up with Google',
    'lg': 'Wandiika nga okozesa Google'
  },
  'noUserFound': {
    'en': 'No user found with that phone or username.',
    'lg': 'Tewali mukozesa afuuse n\'essimu oba erinnya eryo.'
  },
  'incorrectPassword': {
    'en': 'Incorrect password.',
    'lg': 'Pasiwaadi si nnuunji.'
  },
  'loginFailed': {'en': 'Login Failed', 'lg': 'Okuyingira Kulemereddwa'},
  'ok': {'en': 'OK', 'lg': 'Kale'},
  'confirmLogout': {'en': 'Confirm Logout', 'lg': 'Kakasa Okuvamu'},
  'areYouSureLogout': {
    'en': 'Are you sure you want to logout?',
    'lg': 'Oyakakasa nti oyagala kuvaamu?'
  },
  'cancel': {'en': 'Cancel', 'lg': 'Sazaamu'},
  'logoutButton': {'en': 'Logout', 'lg': 'Vamu'},
  'footerNote': {
    'en': 'This app is safe and regulated by the Government of Uganda',
    'lg': 'Eno app yesigika era elondolwa Gavumenti ya Uganda'
  },
};

String t(String key, String lang) {
  return kTranslations[key]?[lang] ?? kTranslations[key]?['en'] ?? key;
}
