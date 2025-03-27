package main

import (
	"./handlers"
	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New()

	// 邮件发送路由
	app.Post("/SendMail", handlers.SendMailHandler)

	app.Listen(":3000")
}
