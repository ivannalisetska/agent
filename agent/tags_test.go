package agent

import (
	"os"
	"reflect"
	"runtime"
	"testing"

	"github.com/buildkite/agent/logger"
	"github.com/stretchr/testify/assert"
)

func TestFetchingTags(t *testing.T) {
	tags := FetchTags(logger.Discard, FetchTagsConfig{
		Tags: []string{"llamas", "rock"},
	})

	if !reflect.DeepEqual(tags, []string{"llamas", "rock"}) {
		t.Fatalf("bad tags: %#v", tags)
	}

	t.Logf("Tags: %#v", tags)
}

func TestFetchingTagsWithHostTags(t *testing.T) {
	tags := FetchTags(logger.Discard, FetchTagsConfig{
		Tags:         []string{"llamas", "rock"},
		TagsFromHost: true,
	})

	assert.Contains(t, tags, "llamas")
	assert.Contains(t, tags, "rock")

	hostname, err := os.Hostname()
	if err != nil {
		t.Fatal(err)
	}

	assert.Contains(t, tags, "hostname="+hostname)
	assert.Contains(t, tags, "os="+runtime.GOOS)
}