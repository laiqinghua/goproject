package handlers

import (
	"log"
	"net/smtp"
	"strconv"

	"github.com/BurntSushi/toml"
	"github.com/gofiber/fiber/v2"
)

type MailConfig struct {
	Gmail struct {
		User     string
		Password string
		SmtpHost string
		SmtpPort int
	}
}

var cfg MailConfig

func init() {
	// 加载配置文件
	if _, err := toml.DecodeFile("config/mail.toml", &cfg); err != nil {
		log.Fatal("Mail config error: ", err)
	}
}

func SendMailHandler(c *fiber.Ctx) error {
	type Request struct {
		Title   string `json:"title"`
		Content string `json:"content"`
	}

	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}

	// 发送邮件逻辑
	auth := smtp.PlainAuth("", cfg.Gmail.User, cfg.Gmail.Password, cfg.Gmail.SmtpHost)
	to := []string{"qinghualai@foxmail.com"}
	msg := []byte(
		"To: qinghualai@foxmail.com\r\n" +
		"Subject: " + req.Title + "\r\n" +
		"\r\n" + req.Content + "\r\n")

	err := smtp.SendMail(
		cfg.Gmail.SmtpHost+":"+strconv.Itoa(cfg.Gmail.SmtpPort),
		auth,
		cfg.Gmail.User,
		to,
		msg,
	)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"status": "sent"})
}
