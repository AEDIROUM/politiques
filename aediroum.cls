\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{aediroum}

\LoadClass[titlepage]{article}

\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[french]{babel}

\RequirePackage{moresize}
\RequirePackage{parskip}
\RequirePackage{marginnote}

\RequirePackage[
    pdfauthor={AÉDIROUM},
    bookmarks=true,
]{hyperref}

\RequirePackage{graphicx}
\renewcommand{\maketitle}{
\begin{titlepage}
\begin{center}
\includegraphics[width=10pc]{logo}

\vfill
{\HUGE \@title}

\vspace{2.5pc}
{\Large Dernière modification~: \@date}
\end{center}

\vfill
\end{titlepage}
}
