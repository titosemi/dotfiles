import os
#import dracula.draw

#dracula.draw.blood(c, {
#    'spacing': {
#        'vertical': 6,
#        'horizontal': 8
#    },
#    'font': {
        #'family': 'Menlo, Terminus, Monaco, Monospace',
#        'family': '"Inconsolata for Powerline"',
#        'size': 12
#    }
#})

home = os.getenv('HOME')
home_bin = home + '/.local/bin'
conf = home + '/.config/qutebrowser'

font_name = '"Inconsolata for Powerline"'
font_size = '12px'
font = font_size + ' ' + font_name

google = 'https://google.com/'
search_google = 'https://google.com/search?hl=en&q={}'
search_google_images = 'https://www.google.com/images?hl=en&q={}'
search_maps = 'https://maps.google.com/maps?q={}'
search_youtube = 'https://www.youtube.com/results?search_query={}'
search_amazon = 'https://www.amazon.de/s?k={}'
search_goodreads = 'https://www.goodreads.com/search?utf8=%E2%9C%93&query={}'
search_php = 'https://php.net/manual-lookup.php?pattern={}&scope=quickref'
search_python = 'https://docs.python.org/3/search.html?q={}'
search_stack_overflow = 'https://stackoverflow.com/search?q={}'
search_jira = 'https://westwing.jira.com/browse/{}'
search_confluence = 'https://westwing.jira.com/wiki/dosearchsite.action?queryString={}'
search_merge_request = 'https://git.westwing.eu/dashboard/merge_requests?scope=all&utf8=%E2%9C%93&state=all&search={}'
search_aur = 'https://aur.archlinux.org/packages/?&K={}'
search_arch_wiki = 'https://wiki.archlinux.org/index.php?title=Special%3ASearch&search={}'
search_arch_forum = 'https://bbs.archlinux.org/search.php?action=search&keywords={}'
search_github = 'https://github.com/search?q={}'
search_wikipedia = 'https://en.wikipedia.org/w/index.php?search={}'

def get_translate_url(to, source='auto'):
    base_url = 'https://translate.google.com/#view=home&op=translate&sl='
    search = '{}'.replace(' ', '+')

    return base_url + source + '&tl=' + to + '&text=' + search

#c.content.user_stylesheets = 'solarized-dark-all-sites.css'

c.tabs.title.format = '{audio}{private}{index}: {current_title}'
c.tabs.title.format_pinned = 'P - {audio}{private}{index}: {current_title}'
c.window.title_format = '{audio}{private} {perc} {title_sep} {current_url}'

c.fonts.monospace = font_name + ', "xos4 Terminus", Terminus, Monospace, "DejaVu Sans Mono", Monaco, "Bitstream Vera Sans Mono", "Andale Mono", "Courier New", Courier, "Liberation Mono", monospace, Fixed, Consolas, Terminal'
c.fonts.completion.entry = font
c.fonts.debug_console = font
c.fonts.downloads = font
c.fonts.hints = '14px ' + font_name
c.fonts.keyhint = font
c.fonts.messages.error = font 
c.fonts.messages.info = font
c.fonts.messages.warning = font
c.fonts.monospace = font_name
c.fonts.prompts = font
c.fonts.statusbar = font
c.fonts.tabs = 'bold ' + font

c.url.default_page = google
c.url.searchengines = {
    'DEFAULT':  search_google,
    'g':        search_google,
    'gi':       search_google_images,
    'm':        search_maps,
    'y':        search_youtube,
    'a':        search_amazon,
    'gr':       search_goodreads,
    'p':        search_php,
    'py':       search_python,
    'so':       search_stack_overflow,
    'j':        search_jira,
    'c':        search_confluence,
    'mr':       search_merge_request,
    'aur':      search_aur,
    'aw':       search_arch_wiki,
    'bbs':      search_arch_forum,
    'gh':       search_github,
    'w':        search_wikipedia,
    'tr':       get_translate_url(to='en'),
    'trenes':   get_translate_url(to='es', source='en'),
    'tresen':   get_translate_url(to='en', source='es'),
    'trdees':   get_translate_url(to='es', source='de'),
    'tresde':   get_translate_url(to='de', source='es'),
    'trende':   get_translate_url(to='de', source='en'),
    'trdeen':   get_translate_url(to='en', source='de') 
}

# Configuration settings
c.session.default_name = 'default'
c.auto_save.session = True
c.history_gap_interval = -1
c.url.start_pages = [google, ]
c.qt.process_model = 'process-per-site'
c.scrolling.smooth = True
c.tabs.position = 'bottom'
c.tabs.new_position.related = 'next'
c.tabs.new_position.unrelated = 'last'
c.downloads.remove_finished = 1 
c.spellcheck.languages = [ 'en-US', 'de-DE', 'es-ES' ]

# Open in editor (Ctrl + E in insert mode)
c.editor.command = ['kitty', '--class=qutebrowser', '--name=qutebrowser', "-e", "vim", "-f", "{file}", "-c", "normal {line}G{column0}l"]

config.set('input.insert_mode.leave_on_load', False, '*://docs.google.com/*')
config.set('input.insert_mode.leave_on_load', False, '*://westwing.jira.com/*')
config.set('input.insert_mode.leave_on_load', False, '*://git.westwing.eu/*')

# Key bindings
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('t', 'open -t')

# Darkmode
c.qt.args = ['blink-settings=darkMode=4']
config.bind(',n', 'config-cycle content.user_stylesheets ' + conf + '/darculized-all-sites.css "" ;; reload')

# Open Videos with Mpv
config.bind('m', 'spawn ' + home_bin + '/ts-mpv {url}')
config.bind(';m', 'hint links spawn ' + home_bin + '/ts-mpv {hint-url}')

## Download with Aria2c
config.bind(';d', 'hint links spawn ' + home_bin + '/qutearia2c {hint-url}')

c.aliases['foo'] = 'message-info laleli'
