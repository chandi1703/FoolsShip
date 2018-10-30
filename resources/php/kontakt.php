<?php
    $email = $_POST["email"];
    $name = $_POST["name"];
    $message = $_POST["message"];
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
    
    #Main
    
    if (isempty($email)){
        $errormessage = showmessage("Email");
    } elseif (isempty($name)){
        $errormessage = showmessage("Name");
    } elseif (isempty($message)) {
        $errormessage = showmessage("Nachricht");
    } elseif (!empty(correctname($name))){
        $err = correctname($name)
    } elseif (!empty(correctemail($email))){
        correctemail($email)
    }
    
    $empfaenger = "testytest1234@mail1a.de";
    $from = "From: " . $name . " <" . $email . ">";
    mail($empfaenger, $betreff, $text, $from);
?>