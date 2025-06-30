using UnityEngine;

public class Kruv : MonoBehaviour
{
    Vector2 na4alo;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        na4alo = transform.position;
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void Umri()
    {
        transform.position = na4alo;
    }
}
