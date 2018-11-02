<?php
    $email = $_POST["email"];
    $name = $_POST["name"];
    $message = $_POST["message"];
    $surname = $_POST["surname"];
    $errormessage = $err = "";
    $betreff = $_POST["betreff"];
    
    function correctemail($email){
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)){
            return "Falsches Emailformat";
        }
    }
    
    function correctname($name){
        if (!preg_match("/^[a-zA-Z ]*$/",$name)){
            return "Namen dürfen nur aus Buchstaben und Leerzeichen bestehen!";
        }
    }
    
    function showmessage($str){
        return "Das " . $str . " Feld darf nicht leer sein!";
    }
    
    function isempty($string){
        $str = trim($message);
        if ($str !== ""){
            return true;
        }
        else{
            return false;
        }
    }
    
    function errmessage($name, $field){
        if ($field == "Email"){
            return $name . " ist keine gültige Emailadresse!";
        } else {
            return $name . " ist kein gültiger " . $field;
        }
    }
    #Main
    $namebool = correctname($name);
    $surnamebool = correctname($surname);
    $emailbool = correctemail($email);
    if (isempty($email)){
        $errormessage = showmessage("Email");
    } elseif (isempty($name)){
        $errormessage = showmessage("Name"); 
    } elseif (isempty($name)){
        $errormessage = showmessage("Vorname");
    } elseif (isempty($message)) {
        $errormessage = showmessage("Nachricht");
    } elseif (!empty($namebool)){
        $err = errmessage($name, "Name");
    } elseif (!empty($surnamebool)){
        $err = errmessage($surname, "Vorname");
    } elseif (!empty($emailbool)){
        $err = errmessage($email, "Emailadresse");
    }
    
    $empfaenger = "testytest1234@mail1a.de";
    $from = "From: " . $name . " " . $surname ." <" . $email . ">";
    $mail = mail($empfaenger, $betreff, $text, $from);
    
?>