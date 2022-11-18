// 日志的level等信息应该从配置文件里读取，配置文件的路径应该从环境变量或者命令行参数里获取
package mylog

import (
	"github.com/dafsic/walter/config"
	"github.com/dafsic/walter/tools/log"
	"go.uber.org/fx"
	"io"
	"os"
	"sync"
)

type LoggingI interface {
	GetLogger(name string) *log.Logger
}

type LoggingT struct {
	mux     sync.Mutex
	lvl     string
	output  io.Writer
	loggers map[string]*log.Logger
}

func (l *LoggingT) GetLogger(name string) *log.Logger {
	l.mux.Lock()
	defer l.mux.Unlock()
	i, ok := l.loggers[name]
	if !ok {
		i = log.NewLogger(l.output, name, log.LogLevelFromString(l.lvl), log.Ldefault)
		l.loggers[name] = i
	}
	return i
}

var once sync.Once
var l LoggingI

func NewMylog(cfg config.ConfigI) LoggingI {
	once.Do(func() {
		var t LoggingT
		t.output = os.Stdout
		t.lvl = cfg.GetCfgElem("logLevel").(string)
		t.loggers = make(map[string]*log.Logger, 8)
		l = &t
	})
	return l
}

var Module = fx.Options(fx.Provide(NewMylog))
