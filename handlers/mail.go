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
	// 从环境变量中读取配置
    user := os.Getenv("GMAIL_USER")
    password := os.Getenv("GMAIL_PASSWORD")
    smtpHost := os.Getenv("GMAIL_SMTP_HOST")
    smtpPortStr := os.Getenv("GMAIL_SMTP_PORT")

    // 尝试将端口号转换为整数
    smtpPort, err := strconv.Atoi(smtpPortStr)
    if err != nil {
        smtpPort = 0
    }

    // 检查是否所有参数都为空
    if user == "" && password == "" && smtpHost == "" && smtpPort == 0 {
        log.Println("Mail config error: All environment variables are empty.")
    }

    // 设置配置
    cfg.Gmail.User = user
    cfg.Gmail.Password = password
    cfg.Gmail.SmtpHost = smtpHost
    cfg.Gmail.SmtpPort = smtpPort
}

func SendMailHandler(c *fiber.Ctx) error {
	type Request struct {
		Title   string `json:"title"`
		Content string `json:"content"`
		ToEmail string `json:"to_email"`
	}

	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}

	// 发送邮件逻辑
	auth := smtp.PlainAuth("", cfg.Gmail.User, cfg.Gmail.Password, cfg.Gmail.SmtpHost)
	to := []string{ToEmail}
	msg := []byte(
		"To: "+ToEmail+"\r\n" +
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
