class Validator {

  String catchFireBaseException(String errorCode){
    String res='';
    switch(errorCode){
      case 'user-not-found':
      res= "This is email is not exist.";
      break;
    }
    return res;
  }
  String? validateEmail(String? email) {
    if (email == null) {
      return 'This field is required';
    } else if (!((email.contains('@gmail') ||
            email.contains('@yahoo') ||
            email.contains('@outlook')) &&
        email.contains('.com'))) {
      return 'Incorrect input';
    } else {
      return null;
    }
  }

  String? validatePassword(String? password) {
    if (password == null) {
      return 'This field is required';
    } else if (password.length < 7) {
      return 'Password is to short it must be more than 7 character .';
    } else if ((password.contains('@gmail.com'))) {
      return 'Incorrect input';
    } else {
      return null;
    }
  }
}
