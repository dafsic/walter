package main

import (
	"fmt"
	"os"

	"github.com/dafsic/walter/version"
	"github.com/urfave/cli/v2"
)

// 这里mylog还没有初始化，不能使用

func main() {
	app := &cli.App{
		Name:    "lotus assistant",
		Usage:   "lotus-assistant command [args]",
		Version: version.DaemonVersion.String(),
		Commands: []*cli.Command{
			runCmd,
			pledgeCmd,
			switchCmd,
			//...
		},
	}
	if err := app.Run(os.Args); err != nil {
		fmt.Printf("%+v\n", err)
		return
	}
}
