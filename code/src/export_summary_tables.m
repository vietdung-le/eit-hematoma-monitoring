function summary = export_summary_tables(varargin)
%EXPORT_SUMMARY_TABLES Compatibility wrapper.

if nargin == 3
    summary = export_case_summaries(varargin{1}, varargin{2}, varargin{3});
else
    error('export_summary_tables:invalidInputs', ...
        'Expected export_summary_tables(outs, cases, cfg)');
end
end
