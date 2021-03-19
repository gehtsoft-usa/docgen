namespace GehtSoft.DocCreator.Parser
{
    public static class SSTool
    {
        public static bool IsInAutoList(DocItem item, out ListItem listItem)
        {
            listItem = null;
            var li = item.LastItem();
            if (li == null || li is string)
                return false;
            if (li is ListItem li1)
            {
                listItem = li1;
                return listItem.Simplified;
            }
            return false;
        }

        public static bool IsInAutoExample(DocItem item, out ExampleItem exampleItem)
        {
            exampleItem = item as ExampleItem;
            return exampleItem?.Simplified ?? false;
        }

        public static bool IsInAutoTable(DocItem item, out TableItem tableItem)
        {
            tableItem = null;
            var li = item.LastItem();
            if (li == null || li is string)
                return false;
            if (li is TableItem ti)
            {
                tableItem = ti;
                return ti.Simplified;
            }
            return false;
        }

        public static bool StartsWith(string line, string pattern, out string remainder)
        {
            int pl = pattern.Length;
            if (line.Length <= pl)
            {
                remainder = null;
                return false;
            }

            if (line.Substring(0, pl) == pattern)
            {
                remainder = line.Substring(pl);
                return true;
            }

            remainder = null;
            return false;
        }
    }
}
