//Use to test if smtp authentication works on an email server

using System.Net;
using System.Net.Mail;
using System.Threading;
using Microsoft.Extensions.Configuration;

class Program
{
    static void Main(string[] args)
    {
        var builder = new ConfigurationBuilder().AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

        IConfiguration config = builder.Build();

        string smtpAuthUsername = config["EmailSettings:SmtpAuthUsername"];
        string smtpAuthPassword = config["EmailSettings:SmtpAuthPassword"];
        string sender = config["EmailSettings:Sender"];
        string recipient = config["EmailSettings:Recipient"];
        string subject = config["EmailSettings:Subject"];
        string body = config["EmailSettings:Body"];

        string smtpHostUrl = config["EmailSettings:SmtpHostUrl"];
        int port = int.Parse(config["EmailSettings:Port"]);
        bool enableSsl = bool.Parse(config["EmailSettings:EnableSsl"]);

        var client = new SmtpClient(smtpHostUrl)
        {
            Port = port,
            Credentials = new NetworkCredential(smtpAuthUsername, smtpAuthPassword),
            EnableSsl = enableSsl
        };

        var message = new MailMessage(sender, recipient, subject, body);

        try
        {
            client.Send(message);
            Console.WriteLine("The email was successfully sent using Smtp.");
            Console.WriteLine("Application will exit in 5 seconds...");
            Thread.Sleep(5000);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Smtp send failed for {smtpAuthUsername} and server {smtpHostUrl} with the exception: {ex.Message}.");
            Console.WriteLine("Application will exit in 10 seconds...");
            Thread.Sleep(10000);
            
        }
    }
}
