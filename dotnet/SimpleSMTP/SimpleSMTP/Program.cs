//Use to test if smtp authentication works on an email server
using System.Net;
using System.Net.Mail;

string smtpAuthUsername = "username here";
string smtpAuthPassword = "password here";
string sender = "sendernamehere@domain.com";
string recipient = "recipientname@domain.com";
string subject = "This is a simple test email";
string body = "This email message is sent from DotNet.";

string smtpHostUrl = "smtp.azurecomm.net";
var client = new SmtpClient(smtpHostUrl)
{
    Port = 587,
    Credentials = new NetworkCredential(smtpAuthUsername, smtpAuthPassword),
    EnableSsl = true
};

var message = new MailMessage(sender, recipient, subject, body);

try
{
    client.Send(message);
    Console.WriteLine("The email was successfully sent using Smtp.");
}
catch (Exception ex)
{
    Console.WriteLine($"Smtp send failed with the exception: {ex.Message}.");
}